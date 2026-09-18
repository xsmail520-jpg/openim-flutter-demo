import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

import '../../../core/controller/im_controller.dart';
import '../../../core/im_callback.dart';
import '../../conversation/conversation_logic.dart';

class GroupListItem {
  const GroupListItem({
    required this.info,
    required this.roleLevel,
  });

  final GroupInfo info;
  final int roleLevel;
}

class GroupListLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final conversationLogic = Get.find<ConversationLogic>();
  final refreshController = RefreshController();
  final groupList = <GroupListItem>[].obs;
  final isInitialLoading = true.obs;

  static const _pageSize = 100;
  int _offset = 0;
  bool _isLoading = false;

  @override
  void onInit() {
    imLogic.imSdkStatusPublishSubject.last.then((status) {
      if (status.status == IMSdkStatus.syncEnded) refreshGroups();
    });
    refreshGroups();
    super.onInit();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> refreshGroups() async {
    if (_isLoading) return;
    _isLoading = true;
    if (groupList.isEmpty) isInitialLoading.value = true;
    try {
      final page = await _loadPage(offset: 0);
      _offset = page.length;
      groupList.assignAll(await _withRole(page));
      _sortGroups();
      refreshController.refreshCompleted();
      if (page.length < _pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.resetNoData();
      }
    } catch (_) {
      refreshController.refreshFailed();
      rethrow;
    } finally {
      _isLoading = false;
      isInitialLoading.value = false;
    }
  }

  Future<void> loadMoreGroups() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final page = await _loadPage(offset: _offset);
      _offset += page.length;
      groupList.addAll(await _withRole(page));
      _sortGroups();
      if (page.length < _pageSize) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    } catch (_) {
      refreshController.loadFailed();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<List<GroupInfo>> _loadPage({required int offset}) =>
      OpenIM.iMManager.groupManager.getJoinedGroupListPage(
        offset: offset,
        count: _pageSize,
      );

  Future<List<GroupListItem>> _withRole(List<GroupInfo> groups) async {
    final result = <GroupListItem>[];
    const batchSize = 20;
    for (var start = 0; start < groups.length; start += batchSize) {
      final end =
          start + batchSize < groups.length ? start + batchSize : groups.length;
      result.addAll(await Future.wait(
        groups.sublist(start, end).map(_resolveRole),
      ));
    }
    return result;
  }

  Future<GroupListItem> _resolveRole(GroupInfo info) async {
    if (info.ownerUserID == OpenIM.iMManager.userID) {
      return GroupListItem(info: info, roleLevel: GroupRoleLevel.owner);
    }

    final members = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupID: info.groupID,
      userIDList: [OpenIM.iMManager.userID],
    );
    return GroupListItem(
      info: info,
      roleLevel: members.isNotEmpty
          ? members.first.roleLevel ?? GroupRoleLevel.member
          : GroupRoleLevel.member,
    );
  }

  void _sortGroups() {
    groupList.sort((left, right) {
      final roleCompare = right.roleLevel.compareTo(left.roleLevel);
      if (roleCompare != 0) return roleCompare;
      return (left.info.groupName ?? '')
          .toLowerCase()
          .compareTo((right.info.groupName ?? '').toLowerCase());
    });
  }

  void toGroupChat(GroupInfo info) {
    conversationLogic.toChat(
      offUntilHome: false,
      groupID: info.groupID,
      nickname: info.groupName,
      faceURL: info.faceURL,
      sessionType: info.sessionType,
    );
  }
}
