import 'config.dart';

class Urls {
  static final onlineStatus =
      "${Config.imApiUrl}/manager/get_users_online_status";
  static final queryAllUsers = "${Config.imApiUrl}/manager/get_all_users_uid";
  static final updateUserInfo = "${Config.appAuthUrl}/user/update";
  static final searchFriendInfo = "${Config.appAuthUrl}/friend/search";
  static final getUsersFullInfo = "${Config.appAuthUrl}/user/find/full";
  static final searchUserFullInfo = "${Config.appAuthUrl}/user/search/full";

  static final getVerificationCode = "${Config.appAuthUrl}/account/code/send";
  static final checkVerificationCode =
      "${Config.appAuthUrl}/account/code/verify";
  static final register = "${Config.appAuthUrl}/account/register";

  static final resetPwd = "${Config.appAuthUrl}/account/password/reset";
  static final changePwd = "${Config.appAuthUrl}/account/password/change";
  static final login = "${Config.appAuthUrl}/account/login";

  static final upgrade = "${Config.appAuthUrl}/app/check";
  static final getClientConfig = '${Config.appAuthUrl}/client_config/get';
  static final getTokenForRTC = "${Config.appAuthUrl}/user/rtc/get_token";
  static final findApplets = "${Config.appAuthUrl}/applet/find";

  static final businessBootstrap = "${Config.appAuthUrl}/business/bootstrap";
  static final walletSummary = "${Config.appAuthUrl}/business/wallet/summary";
  static final walletRechargeOptions =
      "${Config.appAuthUrl}/business/wallet/recharge_options";
  static final walletRechargeCreate =
      "${Config.appAuthUrl}/business/wallet/recharge/create";
  static final walletWithdrawCreate =
      "${Config.appAuthUrl}/business/wallet/withdraw/create";
  static final walletRequests = "${Config.appAuthUrl}/business/wallet/requests";
  static final kycGet = "${Config.appAuthUrl}/business/kyc/get";
  static final kycSubmit = "${Config.appAuthUrl}/business/kyc/submit";
  static final paymentMethodsList =
      "${Config.appAuthUrl}/business/payment_methods/list";
  static final paymentMethodsSave =
      "${Config.appAuthUrl}/business/payment_methods/save";
  static final invitationGet = "${Config.appAuthUrl}/business/invitation/get";
  static final loginSessions =
      "${Config.appAuthUrl}/business/security/sessions";
  static final revokeLoginSession =
      "${Config.appAuthUrl}/business/security/sessions/revoke";
  static final loginAudit =
      "${Config.appAuthUrl}/business/security/login_audit";
}
