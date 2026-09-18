import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

class SearchGroupMemberLogic extends GetxController {
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final resultList = <GroupMembersInfo>[].obs;
  final refreshController = RefreshController();
  final hasSearched = false.obs;

  late GroupInfo groupInfo;
  late String opTypeName;
  late int currentUserRole;

  final int count = 40;
  int _offset = 0;
  int _requestVersion = 0;
  String _submittedKeyword = '';

  String get searchKey => searchCtrl.text.trim();

  bool get isSearchNotResult => hasSearched.value && resultList.isEmpty;

  /// 初始化群组、操作类型及当前操作者角色，搜索结果据此保持原列表权限边界。
  @override
  void onInit() {
    groupInfo = Get.arguments['groupInfo'];
    opTypeName = Get.arguments['opTypeName'] ?? 'view';
    currentUserRole = Get.arguments['currentUserRole'] ?? GroupRoleLevel.member;
    searchCtrl.addListener(_clearEmptyInput);
    super.onInit();
  }

  /// 输入改变时清除旧结果，防止较慢请求覆盖新关键词。
  void onSearchChanged(String value) {
    if (value.trim() != _submittedKeyword) {
      clearList();
    }
  }

  /// 按成员昵称和用户 ID 搜索当前群成员。
  Future<void> search() async {
    final keyword = searchKey;
    if (keyword.isEmpty) {
      clearList();
      focusNode.requestFocus();
      return;
    }

    final requestVersion = ++_requestVersion;
    _submittedKeyword = keyword;
    _offset = 0;
    hasSearched.value = true;
    resultList.clear();
    refreshController.resetNoData();

    var members = await LoadingView.singleton.wrap(
      asyncFunction: () => _searchMembers(keyword: keyword, offset: 0),
    );
    if (!_isCurrentRequest(requestVersion, keyword)) return;

    _offset = members.length;
    resultList.assignAll(members.where(_isVisibleMember));
    while (resultList.isEmpty &&
        members.length == count &&
        _isCurrentRequest(requestVersion, keyword)) {
      members = await _searchMembers(keyword: keyword, offset: _offset);
      if (!_isCurrentRequest(requestVersion, keyword)) return;
      _offset += members.length;
      resultList.addAll(members.where(_isVisibleMember));
    }
    _updateLoadState(members.length);
  }

  /// 分页加载更多匹配成员，并按用户 ID 去重。
  Future<void> loadMore() async {
    if (_submittedKeyword.isEmpty) {
      refreshController.loadNoData();
      return;
    }

    final requestVersion = _requestVersion;
    final keyword = _submittedKeyword;
    try {
      final members = await _searchMembers(keyword: keyword, offset: _offset);
      if (!_isCurrentRequest(requestVersion, keyword)) return;
      _offset += members.length;
      final existingIDs =
          resultList.map((member) => member.userID).whereType<String>().toSet();
      for (final member in members.where(_isVisibleMember)) {
        final userID = member.userID;
        if (userID == null || existingIDs.add(userID)) {
          resultList.add(member);
        }
      }
      _updateLoadState(members.length);
    } catch (_) {
      if (_isCurrentRequest(requestVersion, keyword)) {
        refreshController.loadFailed();
      }
      rethrow;
    }
  }

  /// 把所选成员返回原列表，由原列表按浏览或多选模式继续处理。
  void selectMember(GroupMembersInfo member) {
    final userID = member.userID;
    if (userID == null || userID.isEmpty) return;
    Get.back(result: member);
  }

  /// 清空结果并让未完成请求失效。
  void clearList() {
    _requestVersion++;
    _submittedKeyword = '';
    _offset = 0;
    hasSearched.value = false;
    resultList.clear();
    refreshController.resetNoData();
  }

  /// 释放输入、焦点和分页控制器。
  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    refreshController.dispose();
    super.onClose();
  }

  Future<List<GroupMembersInfo>> _searchMembers({
    required String keyword,
    required int offset,
  }) =>
      OpenIM.iMManager.groupManager.searchGroupMembers(
        groupID: groupInfo.groupID,
        keywordList: [keyword],
        isSearchUserID: true,
        isSearchMemberNickname: true,
        offset: offset,
        count: count,
      );

  bool _isCurrentRequest(int requestVersion, String keyword) =>
      requestVersion == _requestVersion && keyword == searchKey;

  bool _isVisibleMember(GroupMembersInfo member) {
    final isSelf = member.userID == OpenIM.iMManager.userID;
    final excludesSelf = opTypeName == 'call' ||
        opTypeName == 'at' ||
        opTypeName == 'transferRight' ||
        opTypeName == 'del';
    if (excludesSelf && isSelf) return false;

    if (opTypeName == 'del') {
      final role = member.roleLevel ?? GroupRoleLevel.member;
      if (currentUserRole != GroupRoleLevel.owner &&
          currentUserRole != GroupRoleLevel.admin) {
        return false;
      }
      if (role == GroupRoleLevel.owner) return false;
      if (currentUserRole == GroupRoleLevel.admin &&
          role != GroupRoleLevel.member) {
        return false;
      }
    }
    return true;
  }

  void _updateLoadState(int rawCount) {
    if (rawCount < count) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  void _clearEmptyInput() {
    if (searchKey.isEmpty) {
      clearList();
    }
  }
}
