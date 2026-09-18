import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPassword = _oldController.text;
    final newPassword = _newController.text;
    if (!IMUtils.isValidPassword(oldPassword) ||
        !IMUtils.isValidPassword(newPassword)) {
      IMViews.showToast(StrRes.wrongPasswordFormat);
      return;
    }
    if (newPassword != _confirmController.text) {
      IMViews.showToast(StrRes.passwordNotSame);
      return;
    }
    setState(() => _loading = true);
    try {
      final changed = await Apis.changePassword(
        userID: OpenIM.iMManager.userID,
        currentPassword: oldPassword,
        newPassword: newPassword,
      );
      if (!changed) {
        IMViews.showToast(StrRes.passwordChangeFailed);
        return;
      }
      IMViews.showToast(StrRes.passwordChanged);
      if (mounted) Get.back();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          TitleBar.back(title: StrRes.changeLoginPassword, showUnderline: true),
      backgroundColor: Styles.background,
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 28.h),
        children: [
          _passwordField(StrRes.plsEnterOldPwd, _oldController),
          12.verticalSpace,
          _passwordField(StrRes.plsEnterNewPwd, _newController),
          12.verticalSpace,
          _passwordField(StrRes.plsConfirmNewPwd, _confirmController),
          24.verticalSpace,
          SizedBox(
            height: 48.h,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(StrRes.confirm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(String hint, TextEditingController controller) =>
      TextField(
        controller: controller,
        obscureText: true,
        enabled: !_loading,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          filled: true,
          fillColor: Styles.surface,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: const BorderSide(color: Styles.divider),
          ),
        ),
      );
}
