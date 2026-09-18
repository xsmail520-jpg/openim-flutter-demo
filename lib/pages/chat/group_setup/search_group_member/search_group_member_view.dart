import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import 'search_group_member_logic.dart';

class SearchGroupMemberPage extends StatelessWidget {
  static const _brandRed = Color(0xFF9E1B22);
  static const _ink = Color(0xFF172033);
  static const _pageBackground = Color(0xFFF4F6F8);
  static const _border = Color(0xFFD8DDE4);
  static const _muted = Color(0xFF6B7280);

  final logic = Get.find<SearchGroupMemberLogic>();

  SearchGroupMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: _buildSearchBar(context),
        backgroundColor: _pageBackground,
        body: Obx(_buildBody),
      ),
    );
  }

  /// 搜索栏复用现有 SearchBox，并用本页颜色覆盖默认视觉。
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

  /// 搜索前、无结果和结果列表保持明确的三态反馈。
  Widget _buildBody() {
    if (!logic.hasSearched.value) {
      return _buildEmptyState(StrRes.search, initial: true);
    }
    if (logic.isSearchNotResult) {
      return _buildEmptyState(StrRes.searchNotFound);
    }
    return SmartRefresher(
      controller: logic.refreshController,
      enablePullDown: false,
      enablePullUp: true,
      footer: IMViews.buildFooter(),
      onLoading: logic.loadMore,
      child: ListView.separated(
        padding: EdgeInsets.only(top: 8.h),
        itemCount: logic.resultList.length,
        separatorBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(left: 70.w),
          child: const Divider(height: 1, thickness: 1, color: _border),
        ),
        itemBuilder: (_, index) => _buildMemberItem(logic.resultList[index]),
      ),
    );
  }

  Widget _buildMemberItem(GroupMembersInfo member) => Material(
        color: Colors.white,
        child: InkWell(
          onTap: () => logic.selectMember(member),
          child: Container(
            height: 72.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                AvatarView(
                  width: 42.w,
                  height: 42.h,
                  url: member.faceURL,
                  text: member.nickname,
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchKeywordText(
                        text: member.nickname ?? member.userID ?? '',
                        keyText: RegExp.escape(logic.searchKey),
                        style: TextStyle(
                            color: _ink,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500),
                        keyStyle: TextStyle(
                            color: _brandRed,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (member.userID?.isNotEmpty == true) ...[
                        4.verticalSpace,
                        SearchKeywordText(
                          text: member.userID!,
                          keyText: RegExp.escape(logic.searchKey),
                          style: TextStyle(color: _muted, fontSize: 12.sp),
                          keyStyle: TextStyle(
                              color: _brandRed,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (member.roleLevel == GroupRoleLevel.owner)
                  _buildRoleBadge(StrRes.groupOwner),
                if (member.roleLevel == GroupRoleLevel.admin)
                  _buildRoleBadge(StrRes.groupAdmin),
                4.horizontalSpace,
                Icon(Icons.chevron_right_rounded, color: _muted, size: 22.w),
              ],
            ),
          ),
        ),
      );

  Widget _buildRoleBadge(String text) => Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: _brandRed.withValues(alpha: 0.08),
          border: Border.all(color: _brandRed.withValues(alpha: 0.24)),
          borderRadius: BorderRadius.circular(3.r),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: _brandRed, fontSize: 11.sp, fontWeight: FontWeight.w500),
        ),
      );

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
                initial ? Icons.group_outlined : Icons.person_search_outlined,
                color: initial ? _muted : _brandRed,
                size: 28.w,
              ),
            ),
            14.verticalSpace,
            Text(text, style: TextStyle(color: _muted, fontSize: 15.sp)),
          ],
        ),
      );
}
