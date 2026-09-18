import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:openim_common/openim_common.dart';

import 'firebase_options.dart';

enum PushType { FCM, none }

const appID = 'your-app-id';
const appKey = 'your-app-key';
const appSecret = 'your-app-secret';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (_) {
    // Android will still display notification payloads through the system
    // tray; data-only handling is best-effort when Firebase is unavailable.
  }
}

class PushController extends GetxService {
  PushType pushType =
      Platform.isAndroid || Platform.isIOS ? PushType.FCM : PushType.none;
  static void Function(Map<String, dynamic> data)? _onForegroundMessage;
  static void Function(Map<String, dynamic> data)? _onNotificationOpened;

  static void configure({
    void Function(Map<String, dynamic> data)? onForegroundMessage,
    void Function(Map<String, dynamic> data)? onNotificationOpened,
  }) {
    _onForegroundMessage = onForegroundMessage;
    _onNotificationOpened = onNotificationOpened;
  }

  static Future<void> initialize() async {
    if (PushController().pushType != PushType.FCM) return;
    try {
      await FCMPushController()._initialize();
    } catch (e) {
      Logger.print('FCM initialization unavailable: $e');
    }
  }

  /// Logs in the user with the specified alias to the push notification service.
  ///
  /// Depending on the push type configured, it either logs in using the Getui or
  /// FCM push service.
  ///
  /// If using Getui, it binds the alias to the Getui service.
  ///
  /// If using FCM, it listens for token refresh events and logs in, invoking the
  /// provided callback with the new token.
  ///
  /// Throws an assertion error if the FCM push type is selected but the
  /// `onTokenRefresh` callback is not provided.
  ///
  /// - Parameters:
  ///   - alias: The alias to bind to the push notification service for getui.
  ///   - onTokenRefresh: A callback function that is invoked with the refreshed
  ///     token when using FCM. Required if the push type is FCM.
  static void login(String alias,
      {void Function(String token)? onTokenRefresh}) {
    if (PushController().pushType == PushType.FCM) {
      initialize().then((_) async {
        try {
          final token = await FCMPushController()._getToken();
          onTokenRefresh?.call(token);
          FCMPushController()
              ._listenToTokenRefresh((token) => onTokenRefresh?.call(token));
        } catch (e) {
          Logger.print('FCM token unavailable: $e');
        }
      });
    }
  }

  static void logout() {
    if (PushController().pushType == PushType.FCM) {
      FCMPushController()._deleteToken();
    }
  }
}

class FCMPushController {
  static final FCMPushController _instance = FCMPushController._internal();
  factory FCMPushController() => _instance;

  FCMPushController._internal();

  bool _firebaseReady = false;
  bool _listenersConfigured = false;

  Future<void> _initialize() async {
    GooglePlayServicesAvailability? availability =
        GooglePlayServicesAvailability.success;
    if (Platform.isAndroid) {
      availability = await GoogleApiAvailability.instance
          .checkGooglePlayServicesAvailability();
    }
    if (availability == GooglePlayServicesAvailability.serviceInvalid) {
      Logger.print('Google Play Services are not available');
      return;
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    _firebaseReady = true;

    await _requestPermission();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    if (!_listenersConfigured) {
      _configureForegroundNotification();
      _configureBackgroundNotification();
      _listenersConfigured = true;
    }

    return;
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _configureForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final data = Map<String, dynamic>.from(message.data);
      data['title'] ??= message.notification?.title;
      data['body'] ??= message.notification?.body;
      PushController._onForegroundMessage?.call(data);
    });
  }

  void _configureBackgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushController._onNotificationOpened
          ?.call(Map<String, dynamic>.from(message.data));
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        PushController._onNotificationOpened
            ?.call(Map<String, dynamic>.from(message.data));
      }
    });
  }

  Future<String> _getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      throw Exception('FCM Token is null');
    }

    return token;
  }

  Future<void> _deleteToken() {
    if (!_firebaseReady) return Future.value();
    return FirebaseMessaging.instance.deleteToken();
  }

  void _listenToTokenRefresh(void Function(String token) onTokenRefresh) {
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      Logger.print('FCM token refreshed');
      onTokenRefresh(newToken);
    });
  }
}
