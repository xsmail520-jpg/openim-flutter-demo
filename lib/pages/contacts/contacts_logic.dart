import 'dart:async';

import 'package:azlistview/azlistview.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/contacts/group_profile_panel/group_profile_panel_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

import '../../core/controller/im_controller.dart';
import '../home/home_logic.dart';
import 'select_contacts/select_contacts_logic.dart';

class ContactsLogic extends GetxController
    implements ViewUserProfileBridge, SelectContactsBridge, ScanBridge {
  final imLogic = Get.find<IMController>();
  final homeLogic = Get.find<HomeLogic>();

  final friendApplicationList = <UserInfo>[];
  final friendList = <ISUserInfo>[].obs;
  final isFriendListLoading = true.obs;

  StreamSubscription<FriendInfo>? _friendDelSub;
  StreamSubscription<FriendInfo>? _friendAddSub;
  StreamSubscription<FriendInfo>? _friendInfoChangedSub;

  int get friendApplicationCount =>
      homeLogic.unhandledFriendApplicationCount.value;

  int get groupApplicationCount =>
      homeLogic.unhandledGroupApplicationCount.value;

  @override
  void onInit() {
    PackageBridge.selectContactsBridge = this;
    PackageBridge.viewUserProfileBridge = this;
    PackageBridge.scanBridge = this;
    _friendDelSub = imLogic.friendDelSubject.listen(_removeFriend);
    _friendAddSub = imLogic.friendAddSubject.listen(_addFriend);
    _friendInfoChangedSub =
        imLogic.friendInfoChangedSubject.listen(_updateFriend);

    super.onInit();
  }

  @override
  void onReady() {
    refreshFriends();
    super.onReady();
  }

  @override
  void onClose() {
    PackageBridge.selectContactsBridge = null;
    PackageBridge.viewUserProfileBridge = null;
    PackageBridge.scanBridge = null;
    _friendDelSub?.cancel();
    _friendAddSub?.cancel();
    _friendInfoChangedSub?.cancel();
    super.onClose();
  }

  Future<void> refreshFriends() async {
    isFriendListLoading.value = true;
    try {
      const pageSize = 1000;
      final result = <FriendInfo>[];
      while (true) {
        final page = await OpenIM.iMManager.friendshipManager.getFriendListPage(
          offset: result.length,
          count: pageSize,
          filterBlack: true,
        );
        result.addAll(page);
        if (page.length < pageSize) break;
      }

      final users =
          result.map((info) => ISUserInfo.fromJson(info.toJson())).toList();
      friendList.assignAll(
        IMUtils.convertToAZList(users).cast<ISUserInfo>(),
      );
    } finally {
      isFriendListLoading.value = false;
    }
  }

  void _addFriend(FriendInfo info) {
    if (friendList.any((item) => item.userID == info.userID)) return;
    friendList.add(
      IMUtils.setAzPinyinAndTag(ISUserInfo.fromJson(info.toJson()))
          as ISUserInfo,
    );
    SuspensionUtil.sortListBySuspensionTag(friendList);
    SuspensionUtil.setShowSuspensionStatus(friendList);
  }

  void _removeFriend(FriendInfo info) {
    friendList.removeWhere((item) => item.userID == info.userID);
  }

  void _updateFriend(FriendInfo info) {
    _removeFriend(info);
    _addFriend(info);
  }

  void newFriend() => AppNavigator.startFriendRequests();

  void newGroup() => AppNavigator.startGroupRequests();

  void myFriend() => AppNavigator.startFriendList();

  void myGroup() => AppNavigator.startGroupList();

  void searchContacts() => AppNavigator.startGlobalSearch();

  void addContacts() => AppNavigator.startAddContactsMethod();

  void viewFriendInfo(ISUserInfo info) => AppNavigator.startUserProfilePane(
        userID: info.userID!,
        nickname: info.nickname,
        faceURL: info.faceURL,
      );

  @override
  Future<T?>? selectContacts<T>(
    int type, {
    List<String>? defaultCheckedIDList,
    List? checkedList,
    List<String>? excludeIDList,
    bool openSelectedSheet = false,
    String? groupID,
    String? ex,
  }) =>
      AppNavigator.startSelectContacts(
        action: SelAction.values[type],
        defaultCheckedIDList: defaultCheckedIDList,
        checkedList: checkedList,
        excludeIDList: excludeIDList,
        openSelectedSheet: openSelectedSheet,
        groupID: groupID,
        ex: ex,
      );

  @override
  viewUserProfile(String userID, String? nickname, String? faceURL,
          [String? groupID]) =>
      AppNavigator.startUserProfilePane(
        userID: userID,
        nickname: nickname,
        faceURL: faceURL,
        groupID: groupID,
      );

  @override
  scanOutGroupID(String groupID) => AppNavigator.startGroupProfilePanel(
        groupID: groupID,
        joinGroupMethod: JoinGroupMethod.qrcode,
        offAndToNamed: true,
      );

  @override
  scanOutUserID(String userID) =>
      AppNavigator.startUserProfilePane(userID: userID, offAndToNamed: true);
}
