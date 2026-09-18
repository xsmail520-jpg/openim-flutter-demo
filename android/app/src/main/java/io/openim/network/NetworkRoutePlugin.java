package io.openim.network;

import android.app.Activity;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.openim.BuildConfig;

/** Flutter bridge for the app-local proxy. No Android VPN APIs are used. */
public final class NetworkRoutePlugin implements MethodChannel.MethodCallHandler {
    private static final String CHANNEL = "io.openim/network_route";

    private final AppProxyManager proxyManager;

    public NetworkRoutePlugin(Activity activity) {
        proxyManager = AppProxyManager.getInstance(activity);
    }

    public void register(BinaryMessenger messenger) {
        new MethodChannel(messenger, CHANNEL).setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getStatus":
                result.success(buildStatus());
                break;
            case "startProxy":
                proxyManager.start();
                result.success(true);
                break;
            case "stopProxy":
                proxyManager.stop();
                result.success(true);
                break;
            default:
                result.notImplemented();
        }
    }

    private Map<String, Object> buildStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("configured", isNodeConfigured());
        status.put("coreRunning", AppProxyManager.isCoreRunning());
        status.put("mode", AppProxyManager.getModeValue());
        status.put("state", AppProxyManager.getStateValue());
        status.put("error", AppProxyManager.getLastErrorCode());
        status.put("proxyHost", "127.0.0.1");
        status.put("proxyPort", AppProxyManager.getProxyPort());
        status.put("proxyUser", AppProxyManager.getProxyUser());
        status.put("proxyPassword", AppProxyManager.getProxyPassword());
        return status;
    }

    private boolean isNodeConfigured() {
        return BuildConfig.OPENIM_VLESS_URL != null
                && BuildConfig.OPENIM_VLESS_URL.startsWith("vless://");
    }
}
