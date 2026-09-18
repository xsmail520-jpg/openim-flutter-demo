import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

enum NetworkRouteState {
  idle,
  checking,

  /// 仅用于尚未提供内置代理实现的平台兼容路径。
  direct,
  preparingProxy,
  proxy,
  notConfigured,
  unavailable,
}

class LocalProxyConfig {
  const LocalProxyConfig({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
  });

  final String host;
  final int port;
  final String user;
  final String password;

  String get directive => 'PROXY $host:$port';

  void configure(HttpClient client) {
    client.findProxy = (_) => directive;
    client.authenticateProxy = (proxyHost, proxyPort, scheme, realm) async {
      client.addProxyCredentials(
        proxyHost,
        proxyPort,
        realm ?? '',
        HttpClientBasicCredentials(user, password),
      );
      return true;
    };
  }
}

class NativeRouteStatus {
  const NativeRouteStatus({
    required this.configured,
    required this.coreRunning,
    required this.mode,
    required this.state,
    required this.error,
    required this.proxy,
  });

  factory NativeRouteStatus.fromMap(Map<Object?, Object?> value) {
    return NativeRouteStatus(
      configured: value['configured'] == true,
      coreRunning: value['coreRunning'] == true,
      mode: value['mode']?.toString() ?? '',
      state: value['state']?.toString() ?? 'idle',
      error: value['error']?.toString() ?? '',
      proxy: LocalProxyConfig(
        host: value['proxyHost']?.toString() ?? '127.0.0.1',
        port: value['proxyPort'] is int ? value['proxyPort'] as int : 0,
        user: value['proxyUser']?.toString() ?? '',
        password: value['proxyPassword']?.toString() ?? '',
      ),
    );
  }

  final bool configured;
  final bool coreRunning;
  final String mode;
  final String state;
  final String error;
  final LocalProxyConfig proxy;
}

abstract class NetworkRoutePlatform {
  Future<NativeRouteStatus> getStatus();

  Future<bool> startProxy();

  Future<void> stopProxy();
}

class MethodChannelNetworkRoutePlatform implements NetworkRoutePlatform {
  static const _channel = MethodChannel('io.openim/network_route');

  @override
  Future<NativeRouteStatus> getStatus() async {
    final value = await _channel.invokeMapMethod<Object?, Object?>('getStatus');
    return NativeRouteStatus.fromMap(value ?? const {});
  }

  @override
  Future<bool> startProxy() async {
    return await _channel.invokeMethod<bool>('startProxy') ?? false;
  }

  @override
  Future<void> stopProxy() async {
    await _channel.invokeMethod<void>('stopProxy');
  }
}

abstract class NetworkConnectivityProbe {
  Future<bool> canReachChat({LocalProxyConfig? proxy});
}

class ChatConnectivityProbe implements NetworkConnectivityProbe {
  ChatConnectivityProbe({
    this.directTimeout = const Duration(seconds: 2),
    this.proxyTimeout = const Duration(seconds: 8),
  });

  final Duration directTimeout;
  final Duration proxyTimeout;

  /// API and WebSocket hosts must both be reachable through the selected route.
  @override
  Future<bool> canReachChat({LocalProxyConfig? proxy}) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      final checks = await Future.wait([
        _probeHttpEndpoint(Uri.parse(Config.appAuthUrl), proxy),
        _probeHttpEndpoint(_webSocketProbeUri(), proxy),
      ]);
      if (checks.every((reachable) => reachable)) {
        return true;
      }
    }
    return false;
  }

  Uri _webSocketProbeUri() {
    final source = Uri.parse(Config.imWsUrl);
    return source.replace(scheme: source.scheme == 'wss' ? 'https' : 'http');
  }

  Future<bool> _probeHttpEndpoint(
    Uri uri,
    LocalProxyConfig? proxy,
  ) async {
    HttpClient? client;
    final timeout = proxy == null ? directTimeout : proxyTimeout;
    try {
      if (uri.scheme != 'http' && uri.scheme != 'https') return false;
      client = HttpClient()..connectionTimeout = timeout;
      if (proxy == null) {
        // iOS/desktop currently have no equivalent built-in Xray runtime.
        // Android never calls this branch; its route is always the node proxy.
        client.findProxy = (_) => 'DIRECT';
      } else {
        proxy.configure(client);
      }
      final request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
      final response = await request.close().timeout(timeout);
      await response.drain<void>().timeout(timeout);
      return true;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }
}

class AppProxyHttpOverrides extends HttpOverrides {
  AppProxyHttpOverrides._();

  static LocalProxyConfig? _activeProxy;

  /// 路由尚未就绪时拒绝网络请求，避免启动阶段绕过内置代理直连。
  static void installPending() {
    _activeProxy = null;
    HttpOverrides.global = AppProxyHttpOverrides._();
  }

  /// 激活本地出口；闭包读取共享状态，因此早于选路创建的客户端也会生效。
  static void activate(LocalProxyConfig proxy) {
    _activeProxy = proxy;
    if (HttpOverrides.current is! AppProxyHttpOverrides) {
      HttpOverrides.global = AppProxyHttpOverrides._();
    }
  }

  /// 每次请求都读取当前出口；代理未就绪时不提供 DIRECT 回退。
  static String proxyDirective(Uri _) =>
      _activeProxy?.directive ?? 'PROXY 127.0.0.1:1';

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = proxyDirective;
    client.authenticateProxy = (proxyHost, proxyPort, scheme, realm) async {
      final proxy = _activeProxy;
      if (proxy == null) return false;
      client.addProxyCredentials(
        proxyHost,
        proxyPort,
        realm ?? '',
        HttpClientBasicCredentials(proxy.user, proxy.password),
      );
      return true;
    };
    return client;
  }
}

class NetworkRouteController extends GetxController
    with WidgetsBindingObserver {
  NetworkRouteController({
    NetworkRoutePlatform? platform,
    NetworkConnectivityProbe? probe,
    bool? isAndroid,
    this.proxyPollInterval = const Duration(milliseconds: 400),
    this.proxyPollAttempts = 25,
  })  : platform = platform ?? MethodChannelNetworkRoutePlatform(),
        probe = probe ?? ChatConnectivityProbe(),
        isAndroid = isAndroid ?? Platform.isAndroid;

  final NetworkRoutePlatform platform;
  final NetworkConnectivityProbe probe;
  final bool isAndroid;
  final Duration proxyPollInterval;
  final int proxyPollAttempts;

  final state = NetworkRouteState.idle.obs;
  Future<bool>? _inFlight;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        (this.state.value == NetworkRouteState.direct ||
            this.state.value == NetworkRouteState.proxy)) {
      ensureReady();
    }
  }

  /// Concurrent callers share one route selection and one Xray startup.
  Future<bool> ensureReady() {
    final running = _inFlight;
    if (running != null) return running;
    final future = _selectRoute();
    _inFlight = future;
    future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
    return future;
  }

  /// Android 只复用或启动内置节点代理；直连结果不会参与选路。
  Future<bool> _selectRoute() async {
    state.value = NetworkRouteState.checking;
    if (!isAndroid) {
      return _acceptNonAndroidDirect();
    }

    NativeRouteStatus status;
    try {
      status = await platform.getStatus();
    } catch (_) {
      state.value = NetworkRouteState.unavailable;
      return false;
    }

    if (!status.configured) {
      state.value = NetworkRouteState.notConfigured;
      return false;
    }

    if (status.coreRunning && status.mode == 'node') {
      if (await probe.canReachChat(proxy: status.proxy)) {
        _installGlobalProxy(status.proxy);
        state.value = NetworkRouteState.proxy;
        return true;
      }
    }
    if (status.coreRunning) {
      await platform.stopProxy();
    }

    return _startProxy(proxy: status.proxy);
  }

  Future<bool> _acceptNonAndroidDirect() async {
    if (await probe.canReachChat()) {
      state.value = NetworkRouteState.direct;
      return true;
    }
    state.value = NetworkRouteState.unavailable;
    return false;
  }

  /// 启动内置节点代理并确认本地 HTTP 入口可访问后再放行 SDK 初始化。
  Future<bool> _startProxy({
    required LocalProxyConfig proxy,
  }) async {
    state.value = NetworkRouteState.preparingProxy;
    try {
      if (!await platform.startProxy()) {
        state.value = NetworkRouteState.unavailable;
        return false;
      }
      for (var attempt = 0; attempt < proxyPollAttempts; attempt++) {
        await Future<void>.delayed(proxyPollInterval);
        final status = await platform.getStatus();
        if (status.coreRunning && status.state == 'active') {
          if (await probe.canReachChat(proxy: status.proxy)) {
            _installGlobalProxy(status.proxy);
            state.value = NetworkRouteState.proxy;
            return true;
          }
          await platform.stopProxy();
          state.value = NetworkRouteState.unavailable;
          return false;
        }
        if (status.state == 'failed') {
          state.value = NetworkRouteState.unavailable;
          return false;
        }
      }
    } catch (_) {
      // Native errors map to a stable state; node details never reach the UI.
    }
    state.value = NetworkRouteState.unavailable;
    return false;
  }

  void _installGlobalProxy(LocalProxyConfig proxy) {
    AppProxyHttpOverrides.activate(proxy);
  }
}
