import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../routes/app_navigator.dart';
import '../conversation/conversation_logic.dart';

enum LoginType {
  phone(0),
  email(1),
  account(2);

  final int rawValue;

  const LoginType(this.rawValue);

  static LoginType fromRawValue(int rawValue) {
    return values.firstWhere((e) => e.rawValue == rawValue);
  }
}

extension LoginTypeExt on LoginType {
  String get name {
    switch (this) {
      case LoginType.phone:
        return StrRes.phoneNumber;
      case LoginType.email:
        return StrRes.email;
      case LoginType.account:
        return StrRes.account;
    }
  }

  String get hintText {
    switch (this) {
      case LoginType.phone:
        return StrRes.plsEnterPhoneNumber;
      case LoginType.email:
        return StrRes.plsEnterEmail;
      case LoginType.account:
        return StrRes.plsEnterAccount;
    }
  }

  String get exclusiveName {
    switch (this) {
      case LoginType.phone:
        return StrRes.email;
      case LoginType.email:
        return StrRes.phoneNumber;
      case LoginType.account:
        return StrRes.account;
    }
  }
}

class LoginLogic extends GetxController with GetTickerProviderStateMixin {
  final appLogic = Get.find<AppController>();
  final imLogic = Get.find<IMController>();
  final phoneCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final verificationCodeCtrl = TextEditingController();
  final obscureText = true.obs;
  final enabled = false.obs;
  final areaCode = "+86".obs;
  final isPasswordLogin = true.obs;
  final versionInfo = ''.obs;
  final loginType = LoginType.phone.obs;
  String? get email =>
      loginType.value == LoginType.email ? phoneCtrl.text.trim() : null;
  String? get phone =>
      loginType.value == LoginType.phone ? phoneCtrl.text.trim() : null;
  String? get account =>
      loginType.value == LoginType.account ? phoneCtrl.text.trim() : null;
  LoginType operateType = LoginType.phone;

  bool get enableVerificationCodeLogin {
    final value = appLogic.clientConfigMap['enableVerificationCodeLogin'];
    if (value == null) return true;
    return !{'0', 'false', 'no', 'off'}
        .contains(value.toString().trim().toLowerCase());
  }

  FocusNode? accountFocus = FocusNode();
  FocusNode? pwdFocus = FocusNode();

  late TabController tabController;

  _initData() async {
    var map = DataSp.getLoginAccount();
    if (map is Map) {
      String? phoneNumber = map["phoneNumber"];
      String? areaCode = map["areaCode"];

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        phoneCtrl.text = phoneNumber;
      }
      if (areaCode != null && areaCode.isNotEmpty) {
        this.areaCode.value = areaCode;
      }
    }

    loginType.value = LoginType.fromRawValue(DataSp.getLoginType());
    operateType = loginType.value;
    tabController.index = loginType.value.rawValue;
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    pwdCtrl.dispose();
    verificationCodeCtrl.dispose();
    tabController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    _initData();
    phoneCtrl.addListener(_onChanged);
    pwdCtrl.addListener(_onChanged);
    verificationCodeCtrl.addListener(_onChanged);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _refreshClientConfig();
    getPackageInfo();
  }

  Future<void> _refreshClientConfig() async {
    try {
      await appLogic.queryClientConfig();
      if (!enableVerificationCodeLogin && !isPasswordLogin.value) {
        isPasswordLogin.value = true;
        _onChanged();
      }
    } catch (e) {
      Logger.print('query client config failed: $e');
    }
  }

  _onChanged() {
    if (loginType.value == LoginType.account) {
      enabled.value =
          phoneCtrl.text.trim().isNotEmpty && pwdCtrl.text.trim().isNotEmpty;
    } else {
      enabled.value = isPasswordLogin.value &&
              phoneCtrl.text.trim().isNotEmpty &&
              pwdCtrl.text.trim().isNotEmpty ||
          !isPasswordLogin.value &&
              phoneCtrl.text.trim().isNotEmpty &&
              verificationCodeCtrl.text.trim().isNotEmpty;
    }
  }

  login() {
    DataSp.putLoginType(loginType.value.rawValue);
    LoadingView.singleton.wrap(asyncFunction: () async {
      var suc = await _login();
      if (suc) {
        final result = await ConversationLogic.getConversationFirstPage();

        Get.find<CacheController>().resetCache();
        AppNavigator.startMain(conversations: result);
        await Get.find<AppController>().consumePendingPush();
      }
    });
  }

  Future<bool> _login() async {
    try {
      if (!isPasswordLogin.value && !enableVerificationCodeLogin) {
        IMViews.showToast(StrRes.verificationCodeLoginDisabled);
        isPasswordLogin.value = true;
        _onChanged();
        return false;
      }
      if (loginType.value == LoginType.phone) {
        if (phone?.isNotEmpty == true &&
            !IMUtils.isMobile(areaCode.value, phoneCtrl.text)) {
          IMViews.showToast(StrRes.plsEnterRightPhone);
          return false;
        }
      } else if (loginType.value == LoginType.email) {
        if (email?.isNotEmpty == true && !phoneCtrl.text.isEmail) {
          IMViews.showToast(StrRes.plsEnterRightEmail);
          return false;
        }
      } else if (loginType.value == LoginType.account) {
        if (this.account?.isNotEmpty != true) {
          IMViews.showToast(StrRes.plsEnterRightAccount);
          return false;
        }
      }
      final password = IMUtils.emptyStrToNull(pwdCtrl.text);
      final code = IMUtils.emptyStrToNull(verificationCodeCtrl.text);
      final data = await Apis.login(
        areaCode: areaCode.value,
        phoneNumber: phone,
        account: this.account,
        email: email,
        password: isPasswordLogin.value ? password : null,
        verificationCode: isPasswordLogin.value ? null : code,
      );
      final account = {
        "areaCode": areaCode.value,
        "phoneNumber": phoneCtrl.text,
        'loginType': loginType.value.rawValue,
      };
      await DataSp.putLoginCertificate(data);
      await DataSp.putLoginAccount(account);
      Logger.print('IM login certificate received for user: ${data.userID}');
      await imLogic.login(data.userID, data.imToken);
      Logger.print('im login success');
      PushController.login(
        data.userID,
        onTokenRefresh: (token) {
          OpenIM.iMManager.updateFcmToken(
              fcmToken: token,
              expireTime: DateTime.now()
                  .add(Duration(days: 90))
                  .millisecondsSinceEpoch);
        },
      );
      Logger.print('push login success');
      return true;
    } catch (e, s) {
      Logger.print('login e: $e $s');
    }
    return false;
  }

  void togglePasswordType() {
    if (isPasswordLogin.value && !enableVerificationCodeLogin) {
      IMViews.showToast(StrRes.verificationCodeLoginDisabled);
      return;
    }
    isPasswordLogin.value = !isPasswordLogin.value;
    _onChanged();
  }

  void toggleLoginType() {
    if (loginType.value == LoginType.phone) {
      loginType.value = LoginType.email;
    } else {
      loginType.value = LoginType.phone;
    }

    phoneCtrl.text = '';
  }

  Future<bool> getVerificationCode() async {
    if (!enableVerificationCodeLogin) {
      IMViews.showToast(StrRes.verificationCodeLoginDisabled);
      return false;
    }
    if (phone?.isNotEmpty == true &&
        !IMUtils.isMobile(areaCode.value, phoneCtrl.text)) {
      IMViews.showToast(StrRes.plsEnterRightPhone);
      return false;
    }

    if (email?.isNotEmpty == true && !phoneCtrl.text.isEmail) {
      IMViews.showToast(StrRes.plsEnterRightEmail);
      return false;
    }

    return sendVerificationCode();
  }

  Future<bool> sendVerificationCode() {
    if (!enableVerificationCodeLogin) {
      IMViews.showToast(StrRes.verificationCodeLoginDisabled);
      return Future.value(false);
    }
    return LoadingView.singleton.wrap(
      asyncFunction: () => Apis.requestVerificationCode(
        areaCode: areaCode.value,
        phoneNumber: phone,
        email: email,
        usedFor: 3,
      ),
    );
  }

  void openCountryCodePicker() async {
    String? code = await IMViews.showCountryCodePicker();
    if (null != code) areaCode.value = code;
  }

  void registerNow() => AppNavigator.startRegister();

  void forgetPassword() => AppNavigator.startForgetPassword();

  void getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final appName = packageInfo.appName;

    versionInfo.value = '$appName v$version';
  }
}
