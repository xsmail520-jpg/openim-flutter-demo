import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import '../blacklist/blacklist_view.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final _imLogic = Get.find<IMController>();
  bool _updatingFriendSetting = false;

  bool get _lockEnabled => DataSp.getLockScreenPassword()?.isNotEmpty == true;

  bool get _biometricEnabled => DataSp.isEnabledBiometric() == true;

  Future<void> _setAllowAddFriend(bool value) async {
    if (_updatingFriendSetting) return;
    final previous = _imLogic.userInfo.value.allowAddFriend == 1;
    setState(() => _updatingFriendSetting = true);
    try {
      await Apis.updateUserInfo(
        userID: OpenIM.iMManager.userID,
        allowAddFriend: value ? 1 : 0,
      );
      _imLogic.userInfo.update((info) => info?.allowAddFriend = value ? 1 : 0);
    } catch (_) {
      _imLogic.userInfo
          .update((info) => info?.allowAddFriend = previous ? 1 : 0);
      IMViews.showToast(StrRes.settingsUpdateFailed);
    } finally {
      if (mounted) setState(() => _updatingFriendSetting = false);
    }
  }

  Future<void> _setLockCode() async {
    final controller = TextEditingController();
    final value = await Get.dialog<String>(
      AlertDialog(
        title: Text(StrRes.setLockCode),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: InputDecoration(hintText: StrRes.lockCodeHint),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text(StrRes.cancel)),
          FilledButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: Text(StrRes.confirm),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    if (!RegExp(r'^\d{4,12}$').hasMatch(value)) {
      IMViews.showToast(StrRes.lockCodeInvalid);
      return;
    }
    await DataSp.putLockScreenPassword(value);
    if (mounted) setState(() {});
  }

  Future<void> _removeLockCode() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(StrRes.removeLockCode),
        content: Text(StrRes.removeLockCodeHint),
        actions: [
          TextButton(onPressed: Get.back, child: Text(StrRes.cancel)),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(StrRes.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await DataSp.clearLockScreenPassword();
    await DataSp.closeBiometric();
    if (mounted) setState(() {});
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (!enabled) {
      await DataSp.closeBiometric();
      if (mounted) setState(() {});
      return;
    }
    if (!_lockEnabled) {
      IMViews.showToast(StrRes.biometricRequiresLockCode);
      return;
    }
    try {
      if (await IMUtils.checkingBiometric(LocalAuthentication())) {
        await DataSp.openBiometric();
        if (mounted) setState(() {});
      }
    } catch (_) {
      IMViews.showToast(StrRes.biometricUnavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.privacySecurity, showUnderline: true),
      backgroundColor: Styles.background,
      body: Obx(
        () => ListView(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          children: [
            _section([
              _switchRow(
                title: StrRes.allowAddFriend,
                value: _imLogic.userInfo.value.allowAddFriend == 1,
                onChanged: _updatingFriendSetting ? null : _setAllowAddFriend,
              ),
              _row(
                StrRes.blacklist,
                onTap: () => Get.to(() => BlacklistPage()),
              ),
            ]),
            12.verticalSpace,
            _section([
              _row(
                StrRes.lockCode,
                value: _lockEnabled
                    ? StrRes.lockCodeEnabled
                    : StrRes.lockCodeDisabled,
                onTap: _lockEnabled ? _removeLockCode : _setLockCode,
              ),
              _switchRow(
                title: StrRes.biometricUnlock,
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
              ),
            ]),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Text(
                StrRes.lockCodeDescription,
                style: Styles.ts_8E9AB0_12sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(List<Widget> children) => Container(
        color: Styles.surface,
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: const Divider(height: 1),
              ),
          ],
        ]),
      );

  Widget _row(String title, {String? value, VoidCallback? onTap}) => ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) Text(value, style: Styles.ts_8E9AB0_14sp),
            6.horizontalSpace,
            Icon(Icons.chevron_right_rounded, color: Styles.muted, size: 24.w),
          ],
        ),
        onTap: onTap,
      );

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) =>
      ListTile(
        title: Text(title),
        trailing: Switch(
          value: value,
          activeColor: Styles.primary,
          onChanged: onChanged,
        ),
      );
}
