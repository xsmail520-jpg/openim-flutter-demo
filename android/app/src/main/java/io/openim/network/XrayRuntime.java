package io.openim.network;

import android.content.Context;
import android.os.Build;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import dalvik.system.DexClassLoader;
/**
 * Loads libXray outside the app class path. OpenIM SDK and libXray are both
 * gomobile libraries and otherwise contribute conflicting go.Seq classes and
 * libgojni.so files to the same APK.
 */
final class XrayRuntime {
    private static final String RUNTIME_VERSION = "26.8.8";
    private static final String ASSET_ROOT = "xray/";
    // 资源使用 .bin 后缀让 APK 压缩器处理大体积 Xray 库；安装到代码缓存时仍恢复为 libgojni.so。
    private static final String NATIVE_ASSET_NAME = "libgojni.bin";
    private static final Object RUNTIME_LOCK = new Object();
    private static volatile ProtectCallback activeProtectCallback;
    private static Method sharedInvokeMethod;
    private static Method sharedResetDnsMethod;
    private static Method sharedSetDnsMethod;
    private static Object sharedDialerController;

    interface ProtectCallback {
        boolean protect(long fd);
    }

    private final Context context;
    private final ProtectCallback protectCallback;

    XrayRuntime(Context context, ProtectCallback protectCallback) {
        this.context = context.getApplicationContext();
        this.protectCallback = protectCallback;
    }

    synchronized void initialize() throws Exception {
        activeProtectCallback = protectCallback;
        synchronized (RUNTIME_LOCK) {
            if (sharedInvokeMethod != null) {
                return;
            }

            String abi = selectAbi();
            File runtimeDir = new File(context.getCodeCacheDir(), "openim-xray-" + RUNTIME_VERSION);
            File optimizedDir = new File(runtimeDir, "optimized");
            File nativeDir = new File(runtimeDir, abi);
            ensureDirectory(optimizedDir);
            ensureDirectory(nativeDir);

            File dexFile = new File(runtimeDir, "classes.dex");
            File nativeFile = new File(nativeDir, "libgojni.so");
            copyAssetIfNeeded(ASSET_ROOT + "classes.dex", dexFile);
            copyAssetIfNeeded(ASSET_ROOT + abi + "/" + NATIVE_ASSET_NAME, nativeFile);
            if (!nativeFile.setReadable(true, true) || !nativeFile.setExecutable(true, true)) {
                throw new IOException("xray native permissions unavailable");
            }

            ClassLoader parent = context.getClassLoader().getParent();
            DexClassLoader loader = new DexClassLoader(
                    dexFile.getAbsolutePath(),
                    optimizedDir.getAbsolutePath(),
                    nativeDir.getAbsolutePath(),
                    parent);
            Class<?> dialerType = Class.forName("libXray.DialerController", true, loader);
            sharedDialerController = Proxy.newProxyInstance(
                    loader,
                    new Class<?>[]{dialerType},
                    (proxy, method, args) -> {
                        if ("protectFd".equals(method.getName()) && args != null && args.length == 1) {
                            ProtectCallback callback = activeProtectCallback;
                            long fd = ((Number) args[0]).longValue();
                            boolean protectedSocket = callback != null && callback.protect(fd);
                            return protectedSocket;
                        }
                        if ("toString".equals(method.getName())) {
                            return "OpenImXrayDialer";
                        }
                        return false;
                    });

            Class<?> libXrayType = Class.forName("libXray.LibXray", true, loader);
            sharedInvokeMethod = libXrayType.getMethod("invoke", String.class);
            sharedResetDnsMethod = libXrayType.getMethod("resetDNS");
            sharedSetDnsMethod = libXrayType.getMethod("setDNS", dialerType, String.class);
            if (protectCallback != null) {
                libXrayType.getMethod("registerDialerController", dialerType)
                        .invoke(null, sharedDialerController);
                libXrayType.getMethod("registerListenerController", dialerType)
                        .invoke(null, sharedDialerController);
            }
        }
    }

    String invoke(String request) throws Exception {
        return (String) call(sharedInvokeMethod, request);
    }

    void setDns(String dnsServer) throws Exception {
        call(sharedSetDnsMethod, sharedDialerController, dnsServer);
    }

    void resetDns() {
        if (sharedResetDnsMethod == null) {
            return;
        }
        try {
            call(sharedResetDnsMethod);
        } catch (Exception ignored) {
            // Cleanup remains best effort after the native core has stopped.
        }
    }

    private Object call(Method method, Object... args) throws Exception {
        if (method == null) {
            throw new IllegalStateException("xray runtime not initialized");
        }
        try {
            return method.invoke(null, args);
        } catch (InvocationTargetException error) {
            Throwable cause = error.getCause();
            if (cause instanceof Exception) {
                throw (Exception) cause;
            }
            throw error;
        }
    }

    private String selectAbi() throws IOException {
        for (String abi : Build.SUPPORTED_ABIS) {
            if (isSupportedAbi(abi) && hasNativeAsset(abi)) {
                return abi;
            }
        }

        // 不跨 ABI 回退：部分 x86_64 模拟器虽可用 Native Bridge 启动 arm64
        // Flutter UI，但直接加载 arm64 Go/Xray 库会在 CPU 指令检测处崩溃。
        // 模拟器应安装 x86_64 测试包，真机发布则使用 arm64 包。
        throw new IOException("xray asset missing for device abi");
    }

    private boolean hasNativeAsset(String abi) {
        if (!isSupportedAbi(abi)) {
            return false;
        }
        try (InputStream ignored = context.getAssets().open(
                ASSET_ROOT + abi + "/" + NATIVE_ASSET_NAME)) {
            return true;
        } catch (IOException ignored) {
            return false;
        }
    }

    private static boolean isSupportedAbi(String abi) {
        return "arm64-v8a".equals(abi) || "x86_64".equals(abi);
    }

    private void copyAssetIfNeeded(String assetPath, File destination) throws IOException {
        if (destination.isFile() && destination.length() > 0) {
            return;
        }
        File parent = destination.getParentFile();
        if (parent == null) {
            throw new IOException("invalid xray destination");
        }
        ensureDirectory(parent);
        File temporary = new File(parent, destination.getName() + ".tmp");
        try (InputStream input = context.getAssets().open(assetPath);
             FileOutputStream output = new FileOutputStream(temporary, false)) {
            byte[] buffer = new byte[64 * 1024];
            int read;
            while ((read = input.read(buffer)) != -1) {
                output.write(buffer, 0, read);
            }
            output.getFD().sync();
        }
        if (!temporary.renameTo(destination)) {
            throw new IOException("xray asset install failed");
        }
    }

    private static void ensureDirectory(File directory) throws IOException {
        if (!directory.isDirectory() && !directory.mkdirs()) {
            throw new IOException("xray directory unavailable");
        }
    }

}
