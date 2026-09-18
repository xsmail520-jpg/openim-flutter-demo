import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

import '../../routes/app_navigator.dart';
import '../conversation/conversation_logic.dart';

class GlobalSearchLogic extends CommonSearchLogic {
  final conversationLogic = Get.find<ConversationLogic>();
  final textMessageRefreshCtrl = RefreshController();
  final fileMessageRefreshCtrl = RefreshController();
  final contactsList = <dynamic>[].obs;
  final groupList = <GroupInfo>[].obs;
  final textSearchResultItems = <SearchResultItems>[].obs;

  final fileMessageList = <Message>[].obs;
  final index = 0.obs;
  final hasSearched = false.obs;
  final tabs = [
    StrRes.globalSearchAll,
    StrRes.globalSearchContacts,
    StrRes.globalSearchGroup,
    StrRes.globalSearchChatHistory,
    StrRes.globalSearchChatFile,
  ];

  int textMessagePageIndex = 1;
  int fileMessagePageIndex = 1;
  int count = 20;
  int textMessageTotalCount = 0;
  int fileMessageTotalCount = 0;
  int _requestVersion = 0;
  String _submittedKeyword = '';

  /// The legacy "expand chat history" entry reuses this page with a
  /// pre-filled keyword. Keep the normal global-search entry unchanged.
  @override
  void onInit() {
    final arguments = Get.arguments;
    if (arguments is Map) {
      final defaultSearchKey = arguments['defaultSearchKey'];
      if (defaultSearchKey is String && defaultSearchKey.trim().isNotEmpty) {
        index.value = 3;
        searchCtrl.text = defaultSearchKey.trim();
      }
    }
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    if (searchKey.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => search());
    }
  }

  /// 切换分类后沿用当前关键词重新搜索，避免展示上一分类的陈旧结果。
  Future<void> switchTab(int tabIndex) async {
    if (index.value == tabIndex) return;
    index.value = tabIndex;
    if (searchKey.isNotEmpty) {
      await search();
    }
  }

  /// 输入变化后立即失效旧结果，异步请求完成时也不会覆盖新关键词状态。
  void onSearchChanged(String value) {
    if (value.trim() != _submittedKeyword) {
      clearList();
    }
  }

  /// 按当前分类执行联系人、群组及本地消息搜索。
  Future<void> search() async {
    final keyword = searchKey;
    if (keyword.isEmpty) {
      clearList();
      focusNode.requestFocus();
      return;
    }

    final requestVersion = ++_requestVersion;
    _submittedKeyword = keyword;
    hasSearched.value = true;
    textMessagePageIndex = 1;
    fileMessagePageIndex = 1;
    _clearResults();
    _resetRefreshControllers();

    switch (index.value) {
      case 0:
        final result = await LoadingView.singleton.wrap(
          asyncFunction: () => Future.wait<dynamic>([
            searchFriend(),
            searchGroup(),
            searchTextMessage(pageIndex: 1, count: count),
            searchFileMessage(pageIndex: 1, count: count),
          ]),
        );
        if (!_isCurrentRequest(requestVersion, keyword)) return;
        contactsList.assignAll(result[0] as List<FriendInfo>);
        groupList.assignAll(result[1] as List<GroupInfo>);
        _replaceTextResult(result[2] as SearchResult);
        _replaceFileResult(result[3] as SearchResult);
        break;
      case 1:
        final result =
            await LoadingView.singleton.wrap(asyncFunction: searchFriend);
        if (!_isCurrentRequest(requestVersion, keyword)) return;
        contactsList.assignAll(result);
        break;
      case 2:
        final result =
            await LoadingView.singleton.wrap(asyncFunction: searchGroup);
        if (!_isCurrentRequest(requestVersion, keyword)) return;
        groupList.assignAll(result);
        break;
      case 3:
        final result = await LoadingView.singleton.wrap(
          asyncFunction: () => searchTextMessage(pageIndex: 1, count: count),
        );
        if (!_isCurrentRequest(requestVersion, keyword)) return;
        _replaceTextResult(result);
        break;
      case 4:
        final result = await LoadingView.singleton.wrap(
          asyncFunction: () => searchFileMessage(pageIndex: 1, count: count),
        );
        if (!_isCurrentRequest(requestVersion, keyword)) return;
        _replaceFileResult(result);
        break;
    }
  }

  /// 继续加载聊天记录搜索结果，并按会话和消息 ID 去重合并。
  Future<void> loadMoreTextMessages() async {
    if (_submittedKeyword.isEmpty) {
      textMessageRefreshCtrl.loadNoData();
      return;
    }
    final requestVersion = _requestVersion;
    final keyword = _submittedKeyword;
    final tabIndex = index.value;
    final nextPage = textMessagePageIndex + 1;
    try {
      final result = await searchTextMessage(pageIndex: nextPage, count: count);
      if (!_isCurrentRequest(requestVersion, keyword) ||
          index.value != tabIndex ||
          tabIndex != 3) return;
      textMessagePageIndex = nextPage;
      textMessageTotalCount = result.totalCount ?? textMessageTotalCount;
      _mergeTextResult(result.searchResultItems ?? const []);
      _updateTextLoadState();
    } catch (_) {
      if (_isCurrentRequest(requestVersion, keyword) && index.value == 3) {
        textMessageRefreshCtrl.loadFailed();
      }
      rethrow;
    }
  }

  /// 继续加载文件消息，并过滤分页中可能重复返回的消息。
  Future<void> loadMoreFileMessages() async {
    if (_submittedKeyword.isEmpty) {
      fileMessageRefreshCtrl.loadNoData();
      return;
    }
    final requestVersion = _requestVersion;
    final keyword = _submittedKeyword;
    final tabIndex = index.value;
    final nextPage = fileMessagePageIndex + 1;
    try {
      final result = await searchFileMessage(pageIndex: nextPage, count: count);
      if (!_isCurrentRequest(requestVersion, keyword) ||
          index.value != tabIndex ||
          tabIndex != 4) return;
      fileMessagePageIndex = nextPage;
      fileMessageTotalCount = result.totalCount ?? fileMessageTotalCount;
      _mergeFileMessages(_messagesFrom(result));
      _updateFileLoadState();
    } catch (_) {
      if (_isCurrentRequest(requestVersion, keyword) && index.value == 4) {
        fileMessageRefreshCtrl.loadFailed();
      }
      rethrow;
    }
  }

  /// 打开联系人资料页。
  void openContact(FriendInfo info) {
    final userID = info.userID;
    if (userID == null || userID.isEmpty) return;
    AppNavigator.startUserProfilePane(
      userID: userID,
      nickname: info.nickname,
      faceURL: info.faceURL,
    );
  }

  /// 打开已加入群组的会话。
  void openGroup(GroupInfo info) {
    conversationLogic.toChat(
      offUntilHome: false,
      groupID: info.groupID,
      nickname: info.groupName,
      faceURL: info.faceURL,
      sessionType: info.sessionType,
    );
  }

  /// 从搜索结果定位到对应聊天消息。
  void openTextResult(SearchResultItems item) {
    final messages = item.messageList;
    if (messages == null || messages.isEmpty) return;
    _openMessage(messages.first);
  }

  /// 从文件结果定位到对应聊天消息。
  void openFileMessage(Message message) {
    _openMessage(message);
  }

  /// 当前分类是否存在可展示结果。
  bool get hasCurrentResult {
    switch (index.value) {
      case 0:
        return contactsList.isNotEmpty ||
            groupList.isNotEmpty ||
            textSearchResultItems.isNotEmpty ||
            fileMessageList.isNotEmpty;
      case 1:
        return contactsList.isNotEmpty;
      case 2:
        return groupList.isNotEmpty;
      case 3:
        return textSearchResultItems.isNotEmpty;
      case 4:
        return fileMessageList.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  void clearList() {
    _requestVersion++;
    _submittedKeyword = '';
    hasSearched.value = false;
    textMessagePageIndex = 1;
    fileMessagePageIndex = 1;
    textMessageTotalCount = 0;
    fileMessageTotalCount = 0;
    _clearResults();
    _resetRefreshControllers();
  }

  /// 释放搜索分页控制器，避免反复进入页面积累监听资源。
  @override
  void onClose() {
    textMessageRefreshCtrl.dispose();
    fileMessageRefreshCtrl.dispose();
    super.onClose();
  }

  void _clearResults() {
    contactsList.clear();
    groupList.clear();
    textSearchResultItems.clear();
    fileMessageList.clear();
  }

  void _resetRefreshControllers() {
    textMessageRefreshCtrl.resetNoData();
    fileMessageRefreshCtrl.resetNoData();
  }

  bool _isCurrentRequest(int requestVersion, String keyword) =>
      requestVersion == _requestVersion && keyword == searchKey;

  void _replaceTextResult(SearchResult result) {
    textMessageTotalCount = result.totalCount ?? 0;
    textSearchResultItems.assignAll(result.searchResultItems ?? const []);
    _updateTextLoadState();
  }

  void _replaceFileResult(SearchResult result) {
    fileMessageTotalCount = result.totalCount ?? 0;
    fileMessageList.assignAll(_messagesFrom(result));
    _updateFileLoadState();
  }

  List<Message> _messagesFrom(SearchResult result) =>
      (result.searchResultItems ?? const [])
          .expand((item) => item.messageList ?? const <Message>[])
          .toList();

  void _mergeTextResult(List<SearchResultItems> incoming) {
    for (final item in incoming) {
      final existingIndex = textSearchResultItems.indexWhere(
        (element) => element.conversationID == item.conversationID,
      );
      if (existingIndex < 0) {
        textSearchResultItems.add(item);
        continue;
      }

      final existing = textSearchResultItems[existingIndex];
      final messages = existing.messageList ?? <Message>[];
      final messageIDs = messages
          .map((message) => message.clientMsgID)
          .whereType<String>()
          .toSet();
      for (final message in item.messageList ?? const <Message>[]) {
        final messageID = message.clientMsgID;
        if (messageID == null || messageIDs.add(messageID)) {
          messages.add(message);
        }
      }
      existing.messageList = messages;
      existing.messageCount = item.messageCount ?? existing.messageCount;
    }
    textSearchResultItems.refresh();
  }

  void _mergeFileMessages(List<Message> incoming) {
    final messageIDs = fileMessageList
        .map((message) => message.clientMsgID)
        .whereType<String>()
        .toSet();
    for (final message in incoming) {
      final messageID = message.clientMsgID;
      if (messageID == null || messageIDs.add(messageID)) {
        fileMessageList.add(message);
      }
    }
  }

  void _updateTextLoadState() {
    final loadedCount = textSearchResultItems.fold<int>(
      0,
      (total, item) => total + (item.messageList?.length ?? 0),
    );
    if (loadedCount == 0 || loadedCount >= textMessageTotalCount) {
      textMessageRefreshCtrl.loadNoData();
    } else {
      textMessageRefreshCtrl.loadComplete();
    }
  }

  void _updateFileLoadState() {
    if (fileMessageList.isEmpty ||
        fileMessageList.length >= fileMessageTotalCount) {
      fileMessageRefreshCtrl.loadNoData();
    } else {
      fileMessageRefreshCtrl.loadComplete();
    }
  }

  void _openMessage(Message message) {
    if (message.sessionType == ConversationType.single) {
      final peerUserID = message.sendID == OpenIM.iMManager.userID
          ? message.recvID
          : message.sendID;
      if (peerUserID == null || peerUserID.isEmpty) return;
      conversationLogic.toChat(
        offUntilHome: false,
        userID: peerUserID,
        searchMessage: message,
      );
      return;
    }

    final groupID = message.groupID;
    if (groupID == null || groupID.isEmpty) return;
    conversationLogic.toChat(
      offUntilHome: false,
      groupID: groupID,
      sessionType: message.sessionType ?? ConversationType.superGroup,
      searchMessage: message,
    );
  }
}

abstract class CommonSearchLogic extends GetxController {
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();

  void clearList();

  @override
  void onInit() {
    searchCtrl.addListener(_clearInput);
    super.onInit();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  void _clearInput() {
    if (searchKey.isEmpty) {
      clearList();
    }
  }

  String get searchKey => searchCtrl.text.trim();

  Future<List<FriendInfo>> searchFriend() =>
      Apis.searchFriendInfo(searchCtrl.text.trim()).then(
          (list) => list.map((e) => FriendInfo.fromJson(e.toJson())).toList());

  Future<List<GroupInfo>> searchGroup() =>
      OpenIM.iMManager.groupManager.searchGroups(
          keywordList: [searchCtrl.text.trim()],
          isSearchGroupName: true,
          isSearchGroupID: true);

  Future<SearchResult> searchTextMessage({
    int pageIndex = 1,
    int count = 20,
  }) =>
      OpenIM.iMManager.messageManager.searchLocalMessages(
        keywordList: [searchKey],
        messageTypeList: [MessageType.text, MessageType.atText],
        pageIndex: pageIndex,
        count: count,
      );

  Future<SearchResult> searchFileMessage({
    int pageIndex = 1,
    int count = 20,
  }) =>
      OpenIM.iMManager.messageManager.searchLocalMessages(
        keywordList: [searchKey],
        messageTypeList: [MessageType.file],
        pageIndex: pageIndex,
        count: count,
      );

  String? parseID(Object? e) {
    if (e is ConversationInfo) {
      return e.isSingleChat ? e.userID : e.groupID;
    } else if (e is GroupInfo) {
      return e.groupID;
    } else if (e is UserInfo) {
      return e.userID;
    } else if (e is FriendInfo) {
      return e.userID;
    } else {
      return null;
    }
  }

  String? parseNickname(Object? e) {
    if (e is ConversationInfo) {
      return e.showName;
    } else if (e is GroupInfo) {
      return e.groupName;
    } else if (e is UserInfo) {
      return e.nickname;
    } else if (e is FriendInfo) {
      return e.nickname;
    } else {
      return null;
    }
  }

  String? parseFaceURL(Object? e) {
    if (e is ConversationInfo) {
      return e.faceURL;
    } else if (e is GroupInfo) {
      return e.faceURL;
    } else if (e is UserInfo) {
      return e.faceURL;
    } else if (e is FriendInfo) {
      return e.faceURL;
    } else {
      return null;
    }
  }
}
