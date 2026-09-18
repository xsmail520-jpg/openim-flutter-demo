import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_kit/media_kit.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class Config {
  static Future init(Function() runApp) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final path = (await getApplicationDocumentsDirectory()).path;
      cachePath = '$path/';
      await DataSp.init();
      await Hive.initFlutter(path);
      MediaKit.ensureInitialized();
      HttpUtil.init();
    } catch (_) {}

    runApp();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var brightness = Platform.isAndroid ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
    ));

    final packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;
  }

  static late String _appName;

  static late String cachePath;
  static const uiW = 375.0;
  static const uiH = 812.0;

  static const double textScaleFactor = 1.0;

  static const discoverPageURL = 'discover';
  static const allowSendMsgNotFriend = '1';
  // amap key
  static const webKey = 'webKey';
  static const webServerKey = 'webServerKey';
  static const downloadBaseUrl = 'https://6668688.cc';
  static const privacyPolicyUrl = '$downloadBaseUrl/privacy-policy.html';
  static const userAgreementUrl = '$downloadBaseUrl/user-agreement.html';

  static OfflinePushInfo get offlinePushInfo => OfflinePushInfo(
        title: _appName,
        desc: StrRes.offlineMessage,
        iOSBadgeCount: true,
        iOSPushSound: 'default',
      );

  static const friendScheme = "io.openim.app/addFriend/";
  static const groupScheme = "io.openim.app/joinGroup/";

  // 移动端统一使用公网 API 域名；不要把开发机局域网地址打进正式 APK。
  static const _host = "openimapi.hs918.net";
  static const _authUrlOverride = String.fromEnvironment('OPENIM_AUTH_URL');
  static const _apiUrlOverride = String.fromEnvironment('OPENIM_API_URL');
  static const _wsUrlOverride = String.fromEnvironment('OPENIM_WS_URL');

  static const _ipRegex =
      '((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)';

  static bool get _isIP => RegExp(_ipRegex).hasMatch(_host);

  /// Reject loopback endpoints left by old development builds so an upgraded
  /// mobile client falls back to the public service instead of dialing itself.
  static bool _isLoopbackHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized.endsWith('.localhost') ||
        normalized == '::1' ||
        normalized == '0.0.0.0' ||
        normalized == '127.0.0.1' ||
        normalized.startsWith('127.');
  }

  static String? _usableUrl(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    final normalized = value.trim();
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.isEmpty) return null;
    final host = uri.host.toLowerCase();
    if (_isLoopbackHost(host)) return null;
    return normalized;
  }

  static String? _configuredUrl(String key) {
    final server = DataSp.getServerConfig();
    return _usableUrl(server?[key]);
  }

  static String get serverIp {
    String? ip;
    var server = DataSp.getServerConfig();
    if (null != server) {
      ip = server['serverIP'];
    }
    final raw = ip?.trim();
    if (raw == null || raw.isEmpty) return _host;
    final parsed = Uri.tryParse(raw.contains('://') ? raw : 'http://$raw');
    final host = parsed?.host;
    return host == null || host.isEmpty || _isLoopbackHost(host) ? _host : host;
  }

  static String get chatTokenUrl {
    return _configuredUrl('chatTokenUrl') ??
        (_isIP ? "http://$_host:10009" : "https://$_host/chat");
  }

  static String get appAuthUrl {
    return _configuredUrl('authUrl') ??
        _usableUrl(_authUrlOverride) ??
        (_isIP ? "http://$_host:10008" : "https://$_host/chat");
  }

  static String get imApiUrl {
    return _configuredUrl('apiUrl') ??
        _usableUrl(_apiUrlOverride) ??
        (_isIP ? 'http://$_host:10002' : "https://$_host/api");
  }

  static String get imWsUrl {
    return _configuredUrl('wsUrl') ??
        _usableUrl(_wsUrlOverride) ??
        (_isIP ? "ws://$_host:10001" : "wss://$_host/msg_gateway");
  }

  static int get logLevel {
    String? level;
    var server = DataSp.getServerConfig();
    if (null != server) {
      level = server['logLevel'];
    }
    return level == null ? 5 : int.parse(level);
  }
}
