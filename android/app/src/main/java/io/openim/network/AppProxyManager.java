package io.openim.network;

import android.content.Context;
import android.net.Uri;
import android.system.Os;
import android.util.Log;

import org.json.JSONArray;
import org.json.JSONObject;

import java.security.SecureRandom;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicBoolean;

import io.openim.BuildConfig;

/**
 * Runs Xray inside the app process and exposes an authenticated HTTP proxy on loopback only.
 * OpenIM's Go runtime reads the proxy environment configured before Flutter plugins are loaded.
 */
public final class AppProxyManager {
    private static final String LOG_TAG = "OpenImAppProxy";
    private static final String MODE_NODE = "node";
    private static final int PROXY_PORT = 17890;
    private static final int TLS_TUNNEL_PORT = 17891;
    private static final String APP_NODE_HOST = "openimapi.hs918.net";
    private static final int APP_NODE_PORT = 443;
    private static final String APP_NODE_PATH = "/hqmx-connect-6b8f9a2c";
    private static final String PROXY_USER = "openim";
    private static final String PROXY_PASSWORD = randomHex(24);
    private static final AtomicBoolean CORE_RUNNING = new AtomicBoolean(false);
    private static final Object INSTANCE_LOCK = new Object();

    private static volatile AppProxyManager instance;
    private static volatile String stateValue = "idle";
    private static volatile String modeValue = "";
    private static volatile String lastErrorCode = "";

    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private final Object lifecycleLock = new Object();
    private final Context context;
    private XrayRuntime xrayRuntime;
    private AppTlsTunnel tlsTunnel;

    private AppProxyManager(Context context) {
        this.context = context.getApplicationContext();
    }

    public static AppProxyManager getInstance(Context context) {
        AppProxyManager current = instance;
        if (current != null) {
            return current;
        }
        synchronized (INSTANCE_LOCK) {
            if (instance == null) {
                instance = new AppProxyManager(context);
            }
            return instance;
        }
    }

    /** Must run before Flutter registers the OpenIM gomobile plugin. */
    public static void configureProcessEnvironment() {
        String proxyUrl = "http://" + PROXY_USER + ":" + PROXY_PASSWORD
                + "@127.0.0.1:" + PROXY_PORT;
        try {
            Os.setenv("HTTP_PROXY", proxyUrl, true);
            Os.setenv("HTTPS_PROXY", proxyUrl, true);
            Os.setenv("http_proxy", proxyUrl, true);
            Os.setenv("https_proxy", proxyUrl, true);
        } catch (Throwable error) {
            updateState("failed", "proxy_environment_failed");
        }
    }

    /** Starts the only supported outbound: the app-local authenticated node proxy. */
    public void start() {
        worker.execute(this::startInternal);
    }

    public void stop() {
        worker.execute(() -> {
            synchronized (lifecycleLock) {
                stopCore();
                updateState("idle", "");
            }
        });
    }

    private void startInternal() {
        synchronized (lifecycleLock) {
            if (CORE_RUNNING.get() && MODE_NODE.equals(modeValue)) {
                return;
            }
            if (!isNodeConfigured()) {
                updateState("failed", "node_not_configured");
                return;
            }

            stopCore();
            updateState("starting", "");
            try {
                xrayRuntime = new XrayRuntime(context, null);
                xrayRuntime.initialize();
                Uri link = Uri.parse(BuildConfig.OPENIM_VLESS_URL);
                String nodeAddress = link.getHost();
                if (nodeAddress == null || nodeAddress.isEmpty()) {
                    throw new IllegalArgumentException("invalid vless node address");
                }
                tlsTunnel = new AppTlsTunnel(
                        APP_NODE_HOST, nodeAddress, APP_NODE_PORT, TLS_TUNNEL_PORT);
                tlsTunnel.start();
                JSONObject config = buildNodeConfig();
                invokeOrThrow("runXrayFromJson",
                        new JSONObject().put("configJSON", config.toString()));
                modeValue = MODE_NODE;
                CORE_RUNNING.set(true);
                updateState("active", "");
            } catch (Throwable error) {
                Log.e(LOG_TAG, "startup failed: " + errorTypes(error));
                stopCore();
                updateState("failed", "proxy_start_failed");
            }
        }
    }

    private JSONObject buildNodeConfig() throws Exception {
        // 这里应用包网演示服务器节点的 VLESS 身份，并连接 APP 专用的 WSS 入口。
        // Xray 先连 127.0.0.1，AppTlsTunnel 再用 Android 系统 TLS 穿过运营商网络；
        // 全链路只在本 APP 进程内生效，不调用 Android VPN，也不影响其他 APP。
        Uri link = Uri.parse(BuildConfig.OPENIM_VLESS_URL);
        String id = link.getUserInfo();
        String encryption = query(link, "encryption", "none");
        if (id == null || id.isEmpty()) {
            throw new IllegalArgumentException("invalid vless node identity");
        }

        JSONObject user = new JSONObject()
                .put("id", id)
                .put("encryption", encryption);
        JSONObject server = new JSONObject()
                .put("address", "127.0.0.1")
                .put("port", TLS_TUNNEL_PORT)
                .put("users", new JSONArray().put(user));
        JSONObject outbound = new JSONObject()
                .put("protocol", "vless")
                .put("tag", "node")
                .put("settings", new JSONObject()
                        .put("vnext", new JSONArray().put(server)))
                .put("streamSettings", new JSONObject()
                        .put("network", "ws")
                        .put("security", "none")
                        .put("wsSettings", new JSONObject()
                                .put("path", APP_NODE_PATH)
                                .put("host", APP_NODE_HOST)));
        return baseConfig(outbound);
    }

    private static String query(Uri uri, String key, String fallback) {
        String value = uri.getQueryParameter(key);
        return value == null || value.isEmpty() ? fallback : value;
    }

    private JSONObject baseConfig(JSONObject outbound) throws Exception {
        JSONObject account = new JSONObject()
                .put("user", PROXY_USER)
                .put("pass", PROXY_PASSWORD);
        JSONObject inbound = new JSONObject()
                .put("listen", "127.0.0.1")
                .put("port", PROXY_PORT)
                .put("protocol", "http")
                .put("tag", "openim-http")
                .put("settings", new JSONObject()
                        .put("accounts", new JSONArray().put(account)));
        return new JSONObject()
                .put("log", new JSONObject().put("loglevel", "warning"))
                .put("inbounds", new JSONArray().put(inbound))
                .put("outbounds", new JSONArray().put(outbound));
    }

    private JSONObject invokeOrThrow(String method, JSONObject payload) throws Exception {
        XrayRuntime runtime = xrayRuntime;
        if (runtime == null) {
            throw new IllegalStateException("xray runtime unavailable");
        }
        JSONObject request = new JSONObject()
                .put("apiVersion", 1)
                .put("method", method)
                .put("payload", payload);
        JSONObject response = new JSONObject(runtime.invoke(request.toString()));
        if (!response.optBoolean("success", false)) {
            throw new IllegalStateException("xray invocation rejected");
        }
        return response.optJSONObject("data");
    }

    private void stopCore() {
        if (CORE_RUNNING.getAndSet(false) && xrayRuntime != null) {
            try {
                invokeOrThrow("stopXray", new JSONObject());
            } catch (Throwable ignored) {
                // The core may already have exited; cleanup remains idempotent.
            }
        }
        xrayRuntime = null;
        AppTlsTunnel tunnel = tlsTunnel;
        tlsTunnel = null;
        if (tunnel != null) {
            tunnel.stop();
        }
        modeValue = "";
    }

    private static boolean isNodeConfigured() {
        return BuildConfig.OPENIM_VLESS_URL != null
                && BuildConfig.OPENIM_VLESS_URL.startsWith("vless://");
    }

    private static String randomHex(int byteCount) {
        byte[] bytes = new byte[byteCount];
        new SecureRandom().nextBytes(bytes);
        StringBuilder value = new StringBuilder(byteCount * 2);
        for (byte item : bytes) {
            value.append(String.format("%02x", item & 0xff));
        }
        return value.toString();
    }

    private static String errorTypes(Throwable error) {
        StringBuilder summary = new StringBuilder();
        Throwable current = error;
        for (int depth = 0; current != null && depth < 4; depth++) {
            if (summary.length() > 0) summary.append('>');
            summary.append(current.getClass().getSimpleName());
            current = current.getCause();
        }
        return summary.toString();
    }

    private static void updateState(String state, String errorCode) {
        stateValue = state;
        lastErrorCode = errorCode;
        String mode = modeValue.isEmpty() ? "" : ", mode=" + modeValue;
        Log.i(LOG_TAG, errorCode.isEmpty()
                ? "state=" + state + mode
                : "state=" + state + ", code=" + errorCode + mode);
    }

    public static boolean isCoreRunning() {
        return CORE_RUNNING.get();
    }

    public static String getStateValue() {
        return stateValue;
    }

    public static String getModeValue() {
        return modeValue;
    }

    public static String getLastErrorCode() {
        return lastErrorCode;
    }

    public static int getProxyPort() {
        return PROXY_PORT;
    }

    public static String getProxyUser() {
        return PROXY_USER;
    }

    public static String getProxyPassword() {
        return PROXY_PASSWORD;
    }
}
