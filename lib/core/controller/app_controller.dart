import 'dart:io';
import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart' as im;
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:openim/core/im_callback.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:vibration/vibration.dart';

import '../../utils/upgrade_manager.dart';
import '../../routes/app_navigator.dart';
import 'im_controller.dart';

class AppController extends GetxController with UpgradeManger {
  var isRunningBackground = false;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final initializationSettingsAndroid =
      const AndroidInitializationSettings('@drawable/ic_stat_notification');

  final DarwinInitializationSettings initializationSettingsDarwin =
      const DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  RTCBridge? get rtcBridge => PackageBridge.rtcBridge;

  bool get shouldMuted =>
      rtcBridge?.hasConnection == true ||
      Get.find<IMController>().imSdkStatusSubject.values.last.status !=
          IMSdkStatus.syncEnded;

  final _ring = 'assets/audio/message_ring.wav';
  final _audioPlayer = AudioPlayer();
  final configuration = const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.ambient,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.sonification,
      usage: AndroidAudioUsage.notification,
    ),
  );
  late AudioSession session;

  late BaseDeviceInfo deviceInfo;
  Map<String, dynamic>? _pendingPushData;

  final clientConfigMap = <String, dynamic>{}.obs;

  Future<void> runningBackground(bool run) async {
    Logger.print('-----App running background : $run-------------');

    if (isRunningBackground && !run) {}
    isRunningBackground = run;
    if (!run) {
      _cancelAllNotifications();
    }
  }

  @override
  void onInit() async {
    _initPlayer();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final payload = notificationResponse.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          _openNotificationTarget(
              Map<String, dynamic>.from(jsonDecode(payload) as Map));
        } catch (e) {
          Logger.print('notification payload decode failed: $e');
        }
      },
    );

    PushController.configure(
      onForegroundMessage: _showPushNotification,
      onNotificationOpened: _openNotificationTarget,
    );
    PushController.initialize();

    autoCheckVersionUpgrade();
    super.onInit();
  }

  Future<void> showNotification(im.Message message,
      {bool showNotification = true}) async {
    if (_isGlobalNotDisturb() ||
        message.attachedInfoElem?.notSenderNotificationPush == true ||
        message.contentType == im.MessageType.typing ||
        message.sendID == OpenIM.iMManager.userID ||
        (message.contentType! >= 1000 && message.contentType != 1400)) return;

    var sourceID = message.sessionType == ConversationType.single
        ? message.sendID
        : message.groupID;
    if (sourceID != null && message.sessionType != null) {
      var i = await OpenIM.iMManager.conversationManager.getOneConversation(
        sourceID: sourceID,
        sessionType: message.sessionType!,
      );
      if (i.recvMsgOpt != 0) return;
    }

    if (showNotification) {
      String? body;
      try {
        body = IMUtils.parseMsg(message, isConversation: true);
      } catch (_) {}
      promptSoundOrNotification(
        message.seq!,
        title: message.senderNickname,
        body: body,
      );
    }
  }

  Future<void> promptSoundOrNotification(
    int seq, {
    String? title,
    String? body,
  }) async {
    if (Get.find<IMController>().imSdkStatusSubject.values.lastOrNull?.status !=
        IMSdkStatus.syncEnded) {
      return;
    }
    if (!isRunningBackground) {
      _playMessageSound();
    } else {
      if (Platform.isAndroid) {
        final id = seq;

        final user = Get.find<IMController>().userInfo.value;
        final androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'chat',
          '追逐梦',
          channelDescription: '追逐梦消息通知',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_stat_notification',
          ticker: 'ticker',
          playSound: user.allowBeep == 1,
          enableVibration: user.allowVibration == 1,
        );
        final platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
        );
        final preview = DataSp.getNotificationPreview();
        await flutterLocalNotificationsPlugin.show(
            id,
            preview ? (title ?? '追逐梦') : '追逐梦',
            preview ? (body ?? '收到一条新消息') : '收到一条新消息',
            platformChannelSpecifics,
            payload: '');
      }
    }
  }

  Future<void> _showPushNotification(Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    if (_isGlobalNotDisturb()) return;
    final title = '${data['title'] ?? '追逐梦'}';
    final body = DataSp.getNotificationPreview()
        ? '${data['body'] ?? data['desc'] ?? '收到一条新消息'}'
        : '收到一条新消息';
    if (!Platform.isAndroid) return;
    final user = Get.find<IMController>().userInfo.value;
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'chat',
        '追逐梦消息',
        channelDescription: '聊天消息通知',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_stat_notification',
        playSound: user.allowBeep == 1,
        enableVibration: user.allowVibration == 1,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  Future<void> _openNotificationTarget(Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    final ex = data['ex'];
    if (ex is String && ex.isNotEmpty) {
      try {
        final extra = jsonDecode(ex);
        if (extra is Map) {
          data = {...Map<String, dynamic>.from(extra), ...data};
        }
      } catch (_) {}
    }
    if (!Get.isRegistered<IMController>() || OpenIM.iMManager.userID.isEmpty) {
      _pendingPushData = data;
      return;
    }
    final sourceID =
        '${data['sourceID'] ?? data['userID'] ?? data['groupID'] ?? ''}';
    final sessionType =
        int.tryParse('${data['sessionType'] ?? ConversationType.single}');
    if (sourceID.isEmpty || sessionType == null) {
      _pendingPushData = data;
      return;
    }
    try {
      final conversation =
          await OpenIM.iMManager.conversationManager.getOneConversation(
        sourceID: sourceID,
        sessionType: sessionType,
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await AppNavigator.startChat(
          offUntilHome: false, conversationInfo: conversation);
    } catch (e) {
      _pendingPushData = data;
      Logger.print('notification deep link failed: $e');
    }
  }

  Future<void> consumePendingPush() async {
    final data = _pendingPushData;
    _pendingPushData = null;
    if (data != null) await _openNotificationTarget(data);
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void showBadge(count) {
    if (!DataSp.getShowUnreadBadge()) {
      OpenIM.iMManager.messageManager.setAppBadge(0);
      removeBadge();
      return;
    }
    OpenIM.iMManager.messageManager.setAppBadge(count);

    if (count == 0) {
      removeBadge();
    } else {
      AppBadgePlus.isSupported().then((value) {
        if (value) {
          AppBadgePlus.updateBadge(count);
        }
      });
    }
  }

  void removeBadge() {
    AppBadgePlus.isSupported().then((value) {
      if (value) {
        AppBadgePlus.updateBadge(0);
      }
    });
  }

  @override
  void onClose() {
    closeSubject();
    _audioPlayer.dispose();
    super.onClose();
  }

  Locale? getLocale() {
    var local = Get.locale;
    var index = DataSp.getLanguage() ?? 0;
    switch (index) {
      case 1:
        local = const Locale('zh', 'CN');
        break;
      case 2:
        local = const Locale('en', 'US');
        break;
      case 3:
        local = const Locale('zh', 'TW');
        break;
      case 4:
        local = const Locale('vi', 'VN');
        break;
    }
    return local;
  }

  @override
  void onReady() {
    queryClientConfig();
    _getDeviceInfo();
    _cancelAllNotifications();
    super.onReady();
  }

  bool _isGlobalNotDisturb() {
    bool isRegistered = Get.isRegistered<IMController>();
    if (isRegistered) {
      var logic = Get.find<IMController>();
      final value = logic.userInfo.value.globalRecvMsgOpt;
      return value == 1 || value == 2;
    }
    return false;
  }

  void _initPlayer() async {
    session = await AudioSession.instance;
    await session.configure(configuration);

    _audioPlayer.setAsset(_ring, package: 'openim_common');
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
        case ProcessingState.loading:
        case ProcessingState.buffering:
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          _stopMessageSound();

          break;
      }
    });
  }

  void _playMessageSound() async {
    if (shouldMuted) {
      return;
    }
    bool isRegistered = Get.isRegistered<IMController>();
    bool isAllowVibration = true;
    bool isAllowBeep = true;
    if (isRegistered) {
      var logic = Get.find<IMController>();
      isAllowVibration = logic.userInfo.value.allowVibration == 1;
      isAllowBeep = logic.userInfo.value.allowBeep == 1;
    }

    RingerModeStatus ringerStatus = await SoundMode.ringerModeStatus;

    Logger.print(
        'System ringer status: $ringerStatus, user is allow beep: $isAllowBeep',
        fileName: 'app_controller.dart');

    if (!_audioPlayer.playerState.playing &&
        isAllowBeep &&
        (ringerStatus == RingerModeStatus.normal ||
            ringerStatus == RingerModeStatus.unknown)) {
      await session.setActive(true);
      _audioPlayer.setAsset(_ring, package: 'openim_common');
      _audioPlayer.setLoopMode(LoopMode.off);
      _audioPlayer.setVolume(1.0);
      _audioPlayer.play();
    }

    if (isAllowVibration &&
        (ringerStatus == RingerModeStatus.normal ||
            ringerStatus == RingerModeStatus.vibrate ||
            ringerStatus == RingerModeStatus.unknown)) {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate();
      }
    }
  }

  void _stopMessageSound() async {
    if (_audioPlayer.playerState.playing) {
      _audioPlayer.stop();
    }
    await session.setActive(false);
  }

  void _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    deviceInfo = await deviceInfoPlugin.deviceInfo;
  }

  Future queryClientConfig() async {
    final map = await Apis.getClientConfig();
    clientConfigMap.assignAll(map);

    return clientConfigMap;
  }
}
