import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:sprintf/sprintf.dart';

import 'global_search_logic.dart';

class GlobalSearchPage extends StatelessWidget {
  static const _brandRed = Color(0xFF9E1B22);
  static const _ink = Color(0xFF172033);
  static const _pageBackground = Color(0xFFF4F6F8);
  static const _border = Color(0xFFD8DDE4);
  static const _muted = Color(0xFF6B7280);

  final logic = Get.find<GlobalSearchLogic>();

  GlobalSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: _buildSearchBar(context),
        backgroundColor: _pageBackground,
        body: Column(
          children: [
            _buildTabs(),
            Expanded(child: _buildResultBody()),
          ],
        ),
      ),
    );
  }

  /// 使用现有搜索组件构建带返回入口的统一检索栏。
  PreferredSizeWidget _buildSearchBar(BuildContext context) => TitleBar(
        backgroundColor: Colors.white,
        showUnderline: true,
        left: Semantics(
          button: true,
          label: MaterialLocalizations.of(context).backButtonTooltip,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Get.back(),
            child: SizedBox(
              width: Styles.controlHeight,
              height: Styles.controlHeight,
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 19.w, color: _ink),
            ),
          ),
        ),
        center: Expanded(
          child: SearchBox(
            controller: logic.searchCtrl,
            focusNode: logic.focusNode,
            enabled: true,
            autofocus: true,
            backgroundColor: _pageBackground,
            searchIconColor: _muted,
            textStyle: TextStyle(color: _ink, fontSize: 16.sp),
            hintStyle: TextStyle(color: _muted, fontSize: 16.sp),
            onChanged: logic.onSearchChanged,
            onSubmitted: (_) => logic.search(),
            onCleared: logic.focusNode.requestFocus,
          ),
        ),
      );

  /// 分类栏保持扁平、克制，并以政务红标示当前搜索范围。
  Widget _buildTabs() => Obx(
        () {
          final selectedIndex = logic.index.value;
          return Container(
            height: 48.h,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: logic.tabs.length,
              separatorBuilder: (_, __) => 22.horizontalSpace,
              itemBuilder: (_, tabIndex) {
                final selected = selectedIndex == tabIndex;
                return Semantics(
                  selected: selected,
                  button: true,
                  label: logic.tabs[tabIndex],
                  child: InkWell(
                    onTap: () => logic.switchTab(tabIndex),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected ? _brandRed : Colors.transparent,
                            width: 2.h,
                          ),
                        ),
                      ),
                      child: Text(
                        logic.tabs[tabIndex],
                        style: TextStyle(
                          color: selected ? _brandRed : _muted,
                          fontSize: 15.sp,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );

  /// 根据搜索状态和分类选择对应的结果列表。
  Widget _buildResultBody() => Obx(() {
        if (!logic.hasSearched.value) {
          return _buildEmptyState(StrRes.search, initial: true);
        }
        if (!logic.hasCurrentResult) {
          return _buildEmptyState(StrRes.searchNotFound);
        }
        switch (logic.index.value) {
          case 0:
            return _buildAllResults();
          case 1:
            return _buildContactList(
                logic.contactsList.whereType<FriendInfo>().toList());
          case 2:
            return _buildGroupList(logic.groupList);
          case 3:
            return _buildTextResultList();
          case 4:
            return _buildFileResultList();
          default:
            return const SizedBox.shrink();
        }
      });

  /// 综合页按联系人、群组、聊天记录和文件顺序汇总前三项。
  Widget _buildAllResults() {
    final contacts = logic.contactsList.whereType<FriendInfo>().toList();
    final groups = logic.groupList.toList();
    final chats = logic.textSearchResultItems.toList();
    final files = logic.fileMessageList.toList();

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      children: [
        if (contacts.isNotEmpty)
          _buildSection(
            title: StrRes.globalSearchContacts,
            children: contacts.take(3).map(_buildContactItem).toList(),
            moreText:
                contacts.length > 3 ? StrRes.seeMoreRelatedContacts : null,
            onMore: () => logic.switchTab(1),
          ),
        if (groups.isNotEmpty)
          _buildSection(
            title: StrRes.globalSearchGroup,
            children: groups.take(3).map(_buildGroupItem).toList(),
            moreText: groups.length > 3 ? StrRes.seeMoreRelatedGroup : null,
            onMore: () => logic.switchTab(2),
          ),
        if (chats.isNotEmpty)
          _buildSection(
            title: StrRes.globalSearchChatHistory,
            children: chats.take(3).map(_buildTextResultItem).toList(),
            moreText: logic.textMessageTotalCount > 3
                ? StrRes.seeMoreRelatedChatHistory
                : null,
            onMore: () => logic.switchTab(3),
          ),
        if (files.isNotEmpty)
          _buildSection(
            title: StrRes.globalSearchChatFile,
            children: files.take(3).map(_buildFileItem).toList(),
            moreText: logic.fileMessageTotalCount > 3
                ? StrRes.seeMoreRelatedFile
                : null,
            onMore: () => logic.switchTab(4),
          ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    String? moreText,
    required VoidCallback onMore,
  }) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(width: 3.w, height: 16.h, color: _brandRed),
                9.horizontalSpace,
                Text(
                  title,
                  style: TextStyle(
                      color: _ink,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          ..._withDividers(children),
          if (moreText != null)
            InkWell(
              onTap: onMore,
              child: Container(
                height: 42.h,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: Text(
                  moreText,
                  style: TextStyle(
                      color: _brandRed,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactList(List<FriendInfo> contacts) => ListView.separated(
        padding: EdgeInsets.only(top: 8.h),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => _divider,
        itemBuilder: (_, itemIndex) => _buildContactItem(contacts[itemIndex]),
      );

  Widget _buildContactItem(FriendInfo info) => Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => logic.openContact(info),
          child: Container(
            height: 68.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                AvatarView(
                  width: 42.w,
                  height: 42.h,
                  url: info.faceURL,
                  text: info.nickname,
                ),
                12.horizontalSpace,
                Expanded(
                  child: SearchKeywordText(
                    text: info.nickname ?? '',
                    keyText: RegExp.escape(logic.searchKey),
                    style: TextStyle(
                        color: _ink,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500),
                    keyStyle: TextStyle(
                        color: _brandRed,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _muted, size: 22.w),
              ],
            ),
          ),
        ),
      );

  Widget _buildGroupList(List<GroupInfo> groups) => ListView.separated(
        padding: EdgeInsets.only(top: 8.h),
        itemCount: groups.length,
        separatorBuilder: (_, __) => _divider,
        itemBuilder: (_, itemIndex) => _buildGroupItem(groups[itemIndex]),
      );

  Widget _buildGroupItem(GroupInfo info) => Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => logic.openGroup(info),
          child: Container(
            height: 72.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                AvatarView(
                  width: 42.w,
                  height: 42.h,
                  url: info.faceURL,
                  text: info.groupName,
                  isGroup: true,
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchKeywordText(
                        text: info.groupName ?? '',
                        keyText: RegExp.escape(logic.searchKey),
                        style: TextStyle(
                            color: _ink,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500),
                        keyStyle: TextStyle(
                            color: _brandRed,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      4.verticalSpace,
                      Text(
                        sprintf(StrRes.nPerson, [info.memberCount ?? 0]),
                        style: TextStyle(color: _muted, fontSize: 13.sp),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _muted, size: 22.w),
              ],
            ),
          ),
        ),
      );

  Widget _buildTextResultList() => SmartRefresher(
        controller: logic.textMessageRefreshCtrl,
        enablePullDown: false,
        enablePullUp: true,
        footer: IMViews.buildFooter(),
        onLoading: logic.loadMoreTextMessages,
        child: ListView.separated(
          padding: EdgeInsets.only(top: 8.h),
          itemCount: logic.textSearchResultItems.length,
          separatorBuilder: (_, __) => _divider,
          itemBuilder: (_, itemIndex) =>
              _buildTextResultItem(logic.textSearchResultItems[itemIndex]),
        ),
      );

  Widget _buildTextResultItem(SearchResultItems item) {
    final messages = item.messageList ?? const <Message>[];
    final preview = messages.isEmpty
        ? ''
        : IMUtils.parseMsg(messages.first, replaceIdToNickname: true);
    final countText = sprintf(
        StrRes.relatedChatHistory, [item.messageCount ?? messages.length]);
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => logic.openTextResult(item),
        child: Container(
          constraints: BoxConstraints(minHeight: 76.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              AvatarView(
                width: 42.w,
                height: 42.h,
                url: item.faceURL,
                text: item.showName,
                isGroup: item.conversationType != ConversationType.single,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.showName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: _ink,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(countText,
                            style: TextStyle(color: _muted, fontSize: 12.sp)),
                      ],
                    ),
                    5.verticalSpace,
                    SearchKeywordText(
                      text: preview,
                      keyText: RegExp.escape(logic.searchKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _muted, fontSize: 13.sp),
                      keyStyle: TextStyle(
                          color: _brandRed,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileResultList() => SmartRefresher(
        controller: logic.fileMessageRefreshCtrl,
        enablePullDown: false,
        enablePullUp: true,
        footer: IMViews.buildFooter(),
        onLoading: logic.loadMoreFileMessages,
        child: ListView.separated(
          padding: EdgeInsets.only(top: 8.h),
          itemCount: logic.fileMessageList.length,
          separatorBuilder: (_, __) => _divider,
          itemBuilder: (_, itemIndex) =>
              _buildFileItem(logic.fileMessageList[itemIndex]),
        ),
      );

  Widget _buildFileItem(Message message) {
    final fileName = message.fileElem?.fileName ?? StrRes.file;
    final metadata = <String>[
      if (message.senderNickname?.isNotEmpty == true) message.senderNickname!,
      if (message.sendTime != null) IMUtils.getChatTimeline(message.sendTime!),
    ].join('  ·  ');
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => logic.openFileMessage(message),
        child: Container(
          height: 72.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _brandRed.withValues(alpha: 0.08),
                  border: Border.all(color: _brandRed.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(Icons.description_outlined,
                    color: _brandRed, size: 23.w),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchKeywordText(
                      text: fileName,
                      keyText: RegExp.escape(logic.searchKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: _ink,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500),
                      keyStyle: TextStyle(
                          color: _brandRed,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    if (metadata.isNotEmpty) ...[
                      5.verticalSpace,
                      Text(
                        metadata,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _muted, fontSize: 12.sp),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _muted, size: 22.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, {bool initial = false}) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54.w,
              height: 54.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: initial
                    ? _border.withValues(alpha: 0.35)
                    : _brandRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                initial
                    ? Icons.manage_search_rounded
                    : Icons.search_off_rounded,
                color: initial ? _muted : _brandRed,
                size: 28.w,
              ),
            ),
            14.verticalSpace,
            Text(text, style: TextStyle(color: _muted, fontSize: 15.sp)),
          ],
        ),
      );

  List<Widget> _withDividers(List<Widget> children) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) result.add(_divider);
      result.add(children[i]);
    }
    return result;
  }

  Widget get _divider => Padding(
        padding: EdgeInsets.only(left: 70.w),
        child: const Divider(height: 1, thickness: 1, color: _border),
      );
}
