import 'dart:async';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/conversation/conversation_logic.dart';
import 'package:openim_common/openim_common.dart';

import '../../core/controller/im_controller.dart';
import '../../core/controller/app_controller.dart';
import '../../core/network_route/network_route_controller.dart';
import '../privacy/privacy_consent_dialog.dart';
import '../../routes/app_navigator.dart';

class SplashLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final pushLogic = Get.find<PushController>();
  final networkRoute = Get.find<NetworkRouteController>();

  String? get userID => DataSp.userID;

  String? get token => DataSp.imToken;

  late StreamSubscription initializedSub;
  bool _privacyDialogVisible = false;
  bool _routingStarted = false;

  bool get isCheckingNetwork =>
      networkRoute.state.value == NetworkRouteState.checking ||
      networkRoute.state.value == NetworkRouteState.preparingProxy;

  bool get canRetryNetwork =>
      networkRoute.state.value == NetworkRouteState.notConfigured ||
      networkRoute.state.value == NetworkRouteState.unavailable;

  String get networkStatusText {
    switch (networkRoute.state.value) {
      case NetworkRouteState.checking:
        return StrRes.checkingNetwork;
      case NetworkRouteState.preparingProxy:
        return StrRes.connectingNetworkAcceleration;
      case NetworkRouteState.notConfigured:
        return StrRes.networkAccelerationNotConfigured;
      case NetworkRouteState.unavailable:
        return StrRes.networkUnavailableRetry;
      default:
        return '';
    }
  }

  Future<void> retryNetwork() => imLogic.initOpenIM();

  @override
  void onInit() {
    initializedSub = imLogic.initializedSubject.listen((value) {
      if (value == true) _continueAfterInitialization();
    });
    super.onInit();
  }

  Future<void> _continueAfterInitialization() async {
    if (_routingStarted || _privacyDialogVisible) return;

    if (!DataSp.hasPrivacyConsent()) {
      _privacyDialogVisible = true;
      final agreed = await Get.dialog<bool>(
        const PrivacyConsentDialog(),
        barrierDismissible: false,
        useSafeArea: true,
      );
      _privacyDialogVisible = false;
      if (agreed != true) return;
      await DataSp.putPrivacyConsent();
    }

    if (_routingStarted) return;
    _routingStarted = true;
    if (null != userID && null != token) {
      await _login();
    } else {
      AppNavigator.startLogin();
    }
  }

  Future<void> _login() async {
    try {
      Logger.print('---------auto IM login started----------');
      await imLogic.login(userID!, token!);
      Logger.print('---------im login success-------');
      PushController.login(
        userID!,
        onTokenRefresh: (token) {
          OpenIM.iMManager.updateFcmToken(
              fcmToken: token,
              expireTime: DateTime.now()
                  .add(Duration(days: 90))
                  .millisecondsSinceEpoch);
        },
      );
      Logger.print('---------push login success----');
      final result = await ConversationLogic.getConversationFirstPage();

      AppNavigator.startSplashToMain(isAutoLogin: true, conversations: result);
      await Get.find<AppController>().consumePendingPush();
    } catch (e, s) {
      IMViews.showToast('$e $s');
      await DataSp.removeLoginCertificate();
      AppNavigator.startLogin();
    }
  }

  @override
  void onClose() {
    initializedSub.cancel();
    super.onClose();
  }
}
