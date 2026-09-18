package io.openim;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.openim.network.AppProxyManager;
import io.openim.network.NetworkRoutePlugin;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    protected void attachBaseContext(Context newBase) {
        AppProxyManager.configureProcessEnvironment();
        super.attachBaseContext(newBase);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new NetworkRoutePlugin(this).register(flutterEngine.getDartExecutor().getBinaryMessenger());
    }
}
