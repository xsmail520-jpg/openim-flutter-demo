import 'package:flutter_test/flutter_test.dart';
import 'package:openim/core/network_route/network_route_controller.dart';

const testProxy = LocalProxyConfig(
  host: '127.0.0.1',
  port: 17890,
  user: 'test',
  password: 'secret',
);

void main() {
  group('NetworkRouteController', () {
    test('代理未就绪时不允许回退到直连', () {
      AppProxyHttpOverrides.installPending();
      final uri = Uri.parse('https://chat.example.test');

      expect(
        AppProxyHttpOverrides.proxyDirective(uri),
        'PROXY 127.0.0.1:1',
      );
      AppProxyHttpOverrides.activate(testProxy);
      expect(
        AppProxyHttpOverrides.proxyDirective(uri),
        testProxy.directive,
      );

      AppProxyHttpOverrides.installPending();
    });

    test('Android 始终启动内置节点代理，即使直连探测可用', () async {
      final platform = FakeRoutePlatform();
      final probe = FakeProbe([true]);
      final controller = createController(
        platform: platform,
        probe: probe,
      );

      expect(await controller.ensureReady(), isTrue);
      expect(controller.state.value, NetworkRouteState.proxy);
      expect(platform.startRequests, 1);
      expect(platform.mode, 'node');
      expect(probe.probeHadDirectRequest, isFalse);
    });

    test('节点未配置时不启动任何出口', () async {
      final platform = FakeRoutePlatform();
      final controller = createController(
        platform: platform,
        probe: FakeProbe([]),
      );
      platform.configured = false;

      expect(await controller.ensureReady(), isFalse);
      expect(controller.state.value, NetworkRouteState.notConfigured);
      expect(platform.startRequests, 0);
    });

    test('已有 direct 核心不会复用，必须切换到内置节点', () async {
      final platform = FakeRoutePlatform(
        coreRunning: true,
        mode: 'direct',
      );
      final controller = createController(
        platform: platform,
        probe: FakeProbe([true]),
      );

      expect(await controller.ensureReady(), isTrue);
      expect(controller.state.value, NetworkRouteState.proxy);
      expect(platform.stopRequests, 1);
      expect(platform.startRequests, 1);
      expect(platform.mode, 'node');
    });

    test('已有本地代理可用时直接复用', () async {
      final platform = FakeRoutePlatform(
        coreRunning: true,
        mode: 'node',
      );
      final controller = createController(
        platform: platform,
        probe: FakeProbe([true]),
      );

      expect(await controller.ensureReady(), isTrue);
      expect(controller.state.value, NetworkRouteState.proxy);
      expect(platform.startRequests, 0);
    });

    test('已有代理失效时先停止再重新选路', () async {
      final platform = FakeRoutePlatform(
        coreRunning: true,
        mode: 'node',
      );
      final controller = createController(
        platform: platform,
        probe: FakeProbe([false, true, true]),
      );

      expect(await controller.ensureReady(), isTrue);
      expect(platform.stopRequests, 1);
      expect(platform.startRequests, 1);
      expect(controller.state.value, NetworkRouteState.proxy);
    });

    test('本地代理启动失败时返回稳定错误状态', () async {
      final platform = FakeRoutePlatform(startSucceeds: false);
      final controller = createController(
        platform: platform,
        probe: FakeProbe([false]),
      );

      expect(await controller.ensureReady(), isFalse);
      expect(controller.state.value, NetworkRouteState.unavailable);
    });

    test('并发选路只启动一个本地代理实例', () async {
      final platform = FakeRoutePlatform();
      final controller = createController(
        platform: platform,
        probe: FakeProbe([true], delay: Duration.zero),
      );

      final first = controller.ensureReady();
      final second = controller.ensureReady();
      expect(await Future.wait([first, second]), [true, true]);
      expect(platform.startRequests, 1);
    });
  });
}

NetworkRouteController createController({
  required FakeRoutePlatform platform,
  required FakeProbe probe,
}) {
  return NetworkRouteController(
    platform: platform,
    probe: probe,
    isAndroid: true,
    proxyPollInterval: Duration.zero,
    proxyPollAttempts: 2,
  );
}

class FakeProbe implements NetworkConnectivityProbe {
  FakeProbe(this.results, {this.delay = Duration.zero});

  final List<bool> results;
  final Duration delay;
  var calls = 0;
  var probeHadDirectRequest = false;

  @override
  Future<bool> canReachChat({LocalProxyConfig? proxy}) async {
    if (proxy == null) probeHadDirectRequest = true;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final index = calls < results.length ? calls : results.length - 1;
    calls++;
    return results[index];
  }
}

class FakeRoutePlatform implements NetworkRoutePlatform {
  FakeRoutePlatform({
    this.configured = true,
    this.coreRunning = false,
    this.mode = '',
    this.startSucceeds = true,
  });

  bool configured;
  bool coreRunning;
  String mode;
  final bool startSucceeds;

  var startRequests = 0;
  var stopRequests = 0;

  @override
  Future<NativeRouteStatus> getStatus() async {
    return NativeRouteStatus(
      configured: configured,
      coreRunning: coreRunning,
      mode: mode,
      state: coreRunning ? 'active' : 'idle',
      error: '',
      proxy: testProxy,
    );
  }

  @override
  Future<bool> startProxy() async {
    startRequests++;
    if (startSucceeds) {
      coreRunning = true;
      mode = 'node';
    }
    return startSucceeds;
  }

  @override
  Future<void> stopProxy() async {
    stopRequests++;
    coreRunning = false;
    mode = '';
  }
}
