import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';

import 'app.dart';
import 'core/network_route/network_route_controller.dart';

void main() {
  // The OpenIM Go runtime uses process proxy variables; block Dart requests
  // until the app-local Xray proxy is ready instead of falling back to DIRECT.
  AppProxyHttpOverrides.installPending();
  runZonedGuarded(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      Logger.print(
          'FlutterError: ${details.exception.toString()}, ${details.stack.toString()}');
    };

    Config.init(() => runApp(const ChatApp()));
  }, (error, stackTrace) {
    Logger.print('FlutterError: ${error.toString()}, ${stackTrace.toString()}',
        onlyConsole: true);
  });
}
