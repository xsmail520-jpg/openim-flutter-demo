import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/app_controller.dart';
import '../../../core/controller/im_controller.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _imLogic = Get.find<IMController>();
  late bool _display;
  late bool _preview;
  late bool _sound;
  late bool _vibration;
  late bool _badge;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    final user = _imLogic.userInfo.value;
    _display = user.globalRecvMsgOpt != 1;
    _preview = DataSp.getNotificationPreview();
    _sound = user.allowBeep == 1;
    _vibration = user.allowVibration == 1;
    _badge = DataSp.getShowUnreadBadge();
  }

  Future<void> _updateRemote({
    int? globalRecvMsgOpt,
    int? allowBeep,
    int? allowVibration,
  }) async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await Future.wait([
        Apis.updateUserInfo(
          userID: OpenIM.iMManager.userID,
          globalRecvMsgOpt: globalRecvMsgOpt,
          allowBeep: allowBeep,
          allowVibration: allowVibration,
        ),
        if (globalRecvMsgOpt != null)
          OpenIM.iMManager.userManager.setGlobalRecvMessageOpt(
            status: globalRecvMsgOpt,
          ),
      ]);
      _imLogic.userInfo.update((user) {
        if (globalRecvMsgOpt != null) user?.globalRecvMsgOpt = globalRecvMsgOpt;
        if (allowBeep != null) user?.allowBeep = allowBeep;
        if (allowVibration != null) user?.allowVibration = allowVibration;
      });
    } catch (_) {
      IMViews.showToast(StrRes.settingsUpdateFailed);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _setDisplay(bool value) async {
    setState(() => _display = value);
    await _updateRemote(globalRecvMsgOpt: value ? 0 : 1);
  }

  Future<void> _setPreview(bool value) async {
    await DataSp.putNotificationPreview(value);
    if (mounted) setState(() => _preview = value);
  }

  Future<void> _setSound(bool value) async {
    setState(() => _sound = value);
    await _updateRemote(allowBeep: value ? 1 : 0);
  }

  Future<void> _setVibration(bool value) async {
    setState(() => _vibration = value);
    await _updateRemote(allowVibration: value ? 1 : 0);
  }

  Future<void> _setBadge(bool value) async {
    await DataSp.putShowUnreadBadge(value);
    if (mounted) setState(() => _badge = value);
    if (!value) Get.find<AppController>().removeBadge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
          title: StrRes.notificationSettings, showUnderline: true),
      backgroundColor: Styles.background,
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        children: [
          _sectionTitle(StrRes.messageNotifications),
          _switchRow(StrRes.displayNotifications, _display, _setDisplay),
          _switchRow(StrRes.notificationPreview, _preview, _setPreview),
          _switchRow(StrRes.notificationSound, _sound, _setSound),
          _switchRow(StrRes.notificationVibration, _vibration, _setVibration),
          _sectionTitle(StrRes.unreadBadge),
          _switchRow(StrRes.unreadBadge, _badge, _setBadge),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Text(StrRes.notificationSettingsHint,
                style: Styles.ts_8E9AB0_12sp),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: Text(StrRes.conversationNotificationHint,
                style: Styles.ts_8E9AB0_12sp),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
        child: Text(text, style: Styles.ts_8E9AB0_14sp),
      );

  Widget _switchRow(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) =>
      Container(
        color: Styles.surface,
        child: ListTile(
          title: Text(title),
          trailing: Switch(
            value: value,
            activeColor: Styles.primary,
            onChanged: _updating ? null : onChanged,
          ),
        ),
      );
}
