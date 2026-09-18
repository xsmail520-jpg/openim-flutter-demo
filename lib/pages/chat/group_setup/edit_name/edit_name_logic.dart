import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/chat/group_setup/group_setup_logic.dart';
import 'package:openim_common/openim_common.dart';

enum EditNameType {
  myGroupMemberNickname,
  groupNickname,
  groupAnnouncement,
}

class EditGroupNameLogic extends GetxController {
  final groupSetupLogic = Get.find<GroupSetupLogic>();
  late TextEditingController inputCtrl;
  late EditNameType type;
  String? faceUrl;

  @override
  void onInit() {
    type = Get.arguments['type'];
    faceUrl = Get.arguments['faceUrl'];
    inputCtrl = TextEditingController(
      text: type == EditNameType.groupNickname
          ? groupSetupLogic.groupInfo.value.groupName
          : type == EditNameType.groupAnnouncement
              ? groupSetupLogic.groupInfo.value.notification
              : groupSetupLogic.myGroupMembersInfo.value.nickname,
    );
    super.onInit();
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    super.onClose();
  }

  String? get title => type == EditNameType.myGroupMemberNickname
      ? StrRes.myGroupMemberNickname
      : type == EditNameType.groupAnnouncement
          ? '群公告'
          : StrRes.groupName;

  void save() async {
    if (type != EditNameType.groupAnnouncement &&
        inputCtrl.text.trim().length > 16) {
      return IMViews.showToast(StrRes.createGroupTips);
    }
    await LoadingView.singleton.wrap(asyncFunction: () async {
      if (type == EditNameType.groupNickname) {
        await OpenIM.iMManager.groupManager.setGroupInfo(GroupInfo(
            groupID: groupSetupLogic.groupInfo.value.groupID,
            groupName: inputCtrl.text.trim()));
      } else if (type == EditNameType.groupAnnouncement) {
        await OpenIM.iMManager.groupManager.setGroupInfo(GroupInfo(
          groupID: groupSetupLogic.groupInfo.value.groupID,
          notification: inputCtrl.text.trim(),
        ));
      } else if (type == EditNameType.myGroupMemberNickname) {
        await OpenIM.iMManager.groupManager.setGroupMemberNickname(
          groupID: groupSetupLogic.groupInfo.value.groupID,
          userID: OpenIM.iMManager.userID,
          groupNickname: inputCtrl.text.trim(),
        );
      }
    });
    IMViews.showToast(StrRes.setSuccessfully);
    Get.back();
  }
}
