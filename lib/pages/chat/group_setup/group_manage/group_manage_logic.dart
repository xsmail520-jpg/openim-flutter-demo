import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/chat/group_setup/group_setup_logic.dart';
import 'package:openim_common/openim_common.dart';

import '../../../../routes/app_navigator.dart';
import '../group_member_list/group_member_list_logic.dart';

class GroupManageLogic extends GetxController {
  final groupSetupLogic = Get.find<GroupSetupLogic>();

  Rx<GroupInfo> get groupInfo => groupSetupLogic.groupInfo;

  bool get isGroupLocked => groupInfo.value.status == 3;

  bool get privacyEnabled =>
      groupInfo.value.lookMemberInfo == 1 &&
      groupInfo.value.applyMemberFriend == 1;

  Future<void> changeGroupLock(bool locked) async {
    await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.groupManager.changeGroupMute(
        groupID: groupInfo.value.groupID,
        mute: locked,
      ),
    );
    groupInfo.update((value) => value?.status = locked ? 3 : 0);
  }

  Future<void> changeGroupPrivacy(bool enabled) async {
    await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.groupManager.setGroupInfo(
        GroupInfo(
          groupID: groupInfo.value.groupID,
          lookMemberInfo: enabled ? 1 : 0,
          applyMemberFriend: enabled ? 1 : 0,
        ),
      ),
    );
    groupInfo.update((value) {
      value?.lookMemberInfo = enabled ? 1 : 0;
      value?.applyMemberFriend = enabled ? 1 : 0;
    });
  }

  void transferGroupOwnerRight() async {
    var result = await AppNavigator.startGroupMemberList(
      groupInfo: groupInfo.value,
      opType: GroupMemberOpType.transferRight,
    );
    if (result is GroupMembersInfo) {
      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.groupManager.transferGroupOwner(
          groupID: groupInfo.value.groupID,
          userID: result.userID!,
        ),
      );
      groupInfo.update((val) {
        val?.ownerUserID = result.userID;
      });
      Get.back();
    }
  }
}
