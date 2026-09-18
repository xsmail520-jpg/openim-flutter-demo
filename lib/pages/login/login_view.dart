import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  final logic = Get.find<LoginLogic>();

  LoginPage({super.key});

  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarColor: Styles.surface,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  /// 登录页保持白色系统栏和可滚动单列结构，键盘出现时不挤压核心操作。
  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiStyle,
      child: Material(
        color: Styles.surface,
        child: TouchCloseSoftKeyboard(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20.h + keyboardInset),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBrandHeader(),
                        28.verticalSpace,
                        Text(
                          StrRes.welcome,
                          style: Styles.ts_0C1C33_20sp_semibold.copyWith(
                            height: 1.35,
                          ),
                        ),
                        22.verticalSpace,
                        _buildInputView(),
                        16.verticalSpace,
                        Obx(() => Button(
                              text: StrRes.login,
                              enabled: logic.enabled.value,
                              onTap: logic.login,
                            )),
                        8.verticalSpace,
                        Obx(
                          () => Visibility(
                            visible: logic.loginType.value != LoginType.account,
                            child: _buildRegisterAction(),
                          ),
                        ),
                        8.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 登录页统一展示追逐梦品牌标志与产品名。
  Widget _buildBrandHeader() => Row(
        children: [
          ImageRes.loginLogo.toImage
            ..width = 36.w
            ..height = 36.h,
          10.horizontalSpace,
          Text(
            '追逐梦',
            style: Styles.ts_0C1C33_20sp_semibold,
          ),
        ],
      );

  Widget _buildInputView() {
    return Column(
      children: [
        TabBar(
          tabs: LoginType.values.map((e) => Tab(text: e.name)).toList(),
          controller: logic.tabController,
          isScrollable: false,
          indicatorColor: Styles.primary,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Styles.primary,
          unselectedLabelColor: Styles.muted,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          dividerColor: Styles.divider,
          dividerHeight: Styles.dividerWidth,
          onTap: (index) {
            logic.loginType.value = LoginType.fromRawValue(index);
            logic.operateType = logic.loginType.value;
            FocusScope.of(Get.context!).unfocus();
            logic.phoneCtrl.clear();
            logic.pwdCtrl.clear();
          },
        ),
        SizedBox(
          // 英文辅助操作文案略高，预留余量避免小数像素取整造成溢出。
          height: 204,
          child: Obx(
            () => TabBarView(
              controller: logic.tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildInputView1(LoginType.phone),
                _buildInputView1(LoginType.email),
                _buildInputView2(LoginType.account),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputView1(LoginType type) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InputBox.account(
          label: '',
          hintText: type.hintText,
          code: logic.areaCode.value,
          onAreaCode:
              type == LoginType.phone ? logic.openCountryCodePicker : null,
          controller: logic.phoneCtrl,
          focusNode: logic.accountFocus,
          keyBoardType: type == LoginType.phone
              ? TextInputType.phone
              : TextInputType.text,
        ),
        8.verticalSpace,
        Offstage(
          offstage: !logic.isPasswordLogin.value,
          child: InputBox.password(
            label: '',
            hintText: StrRes.plsEnterPassword,
            controller: logic.pwdCtrl,
            focusNode: logic.pwdFocus,
          ),
        ),
        Offstage(
          offstage: logic.isPasswordLogin.value,
          child: InputBox.verificationCode(
            label: StrRes.verificationCode,
            hintText: StrRes.plsEnterVerificationCode,
            controller: logic.verificationCodeCtrl,
            onSendVerificationCode: logic.getVerificationCode,
          ),
        ),
        4.verticalSpace,
        Row(
          children: [
            _buildTextAction(
              text: StrRes.forgetPassword,
              onTap: logic.forgetPassword,
              alignment: Alignment.centerLeft,
              style: Styles.ts_8E9AB0_12sp,
            ),
            const Spacer(),
            if (!logic.isPasswordLogin.value ||
                logic.enableVerificationCodeLogin)
              _buildTextAction(
                text: logic.isPasswordLogin.value
                    ? StrRes.verificationCodeLogin
                    : StrRes.passwordLogin,
                onTap: logic.togglePasswordType,
                alignment: Alignment.centerRight,
                style: Styles.ts_0089FF_12sp,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextAction({
    required String text,
    required VoidCallback onTap,
    required AlignmentGeometry alignment,
    required TextStyle style,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: Styles.controlHeight,
              minHeight: Styles.controlHeight,
            ),
            alignment: alignment,
            child: Text(text, style: style),
          ),
        ),
      );

  Widget _buildRegisterAction() => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showRegisterBottomSheet,
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          child: SizedBox(
            height: Styles.controlHeight,
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: StrRes.noAccountYet,
                  style: Styles.ts_8E9AB0_12sp,
                  children: [
                    TextSpan(
                      text: StrRes.registerNow,
                      style: Styles.ts_0089FF_12sp.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildInputView2(LoginType type) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InputBox.account(
          label: '',
          hintText: type.hintText,
          code: logic.areaCode.value,
          onAreaCode: null,
          controller: logic.phoneCtrl,
          focusNode: logic.accountFocus,
          keyBoardType: TextInputType.text,
        ),
        8.verticalSpace,
        InputBox.password(
          label: '',
          hintText: StrRes.plsEnterPassword,
          controller: logic.pwdCtrl,
          focusNode: logic.pwdFocus,
        ),
      ],
    );
  }

  void _showRegisterBottomSheet() {
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                logic.operateType = LoginType.email;
                logic.registerNow();
              },
              child: Text('${StrRes.email} ${StrRes.registerNow}'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                logic.operateType = LoginType.phone;
                logic.registerNow();
              },
              child: Text('${StrRes.phoneNumber} ${StrRes.registerNow}'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(StrRes.cancel),
          ),
        );
      },
    );
  }
}
