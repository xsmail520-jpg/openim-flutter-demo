import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

import 'add_by_search_logic.dart';

class AddContactsBySearchPage extends StatelessWidget {
  final logic = Get.find<AddContactsBySearchLogic>();

  AddContactsBySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: logic.isSearchUser ? StrRes.addFriend : StrRes.addGroup,
        showUnderline: true,
      ),
      backgroundColor: Styles.background,
      body: Column(
        children: [
          Container(
            color: Styles.surface,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: SearchBox(
              focusNode: logic.focusNode,
              controller: logic.searchCtrl,
              hintText: logic.isSearchUser
                  ? StrRes.searchByPhoneAndUid
                  : StrRes.searchIDAddGroup,
              enabled: true,
              autofocus: true,
              margin: EdgeInsets.zero,
              onSubmitted: (_) => logic.search(),
            ),
          ),
          const Divider(height: Styles.dividerWidth),
          Obx(
            () => Expanded(
              child: logic.isSearchUser
                  ? (logic.isNotFoundUser
                      ? _buildNotFoundView()
                      : _buildUserListView())
                  : (logic.isNotFoundGroup
                      ? _buildNotFoundView()
                      : _buildGroupListView()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListView() => SmartRefresher(
        controller: logic.refreshCtrl,
        enablePullDown: false,
        enablePullUp: true,
        footer: IMViews.buildFooter(),
        onLoading: logic.loadMoreUser,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          itemCount: logic.userInfoList.length,
          itemBuilder: (_, index) {
            final userInfo = logic.userInfoList.elementAt(index);
            return _buildItemView(userInfo);
          },
        ),
      );

  Widget _buildGroupListView() => ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        itemCount: logic.groupInfoList.length,
        itemBuilder: (_, index) => _buildItemView(logic.groupInfoList[index]),
      );

  /// 检索结果保持连续行结构，图标区与标题区形成稳定的扫描层级。
  Widget _buildItemView(dynamic info) => Ink(
        color: Styles.surface,
        child: InkWell(
          onTap: () => logic.viewInfo(info),
          child: Container(
            constraints: BoxConstraints(minHeight: 64.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: const BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(
                  color: Styles.divider,
                  width: Styles.dividerWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Styles.primaryContainer,
                    borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                  ),
                  child: (logic.isSearchUser
                          ? ImageRes.searchPersonIcon
                          : ImageRes.searchGroupIcon)
                      .toImage
                    ..width = 22.w
                    ..height = 22.h
                    ..color = Styles.primary,
                ),
                12.horizontalSpace,
                Expanded(
                  child: logic.getShowTitle(info).toText
                    ..style = Styles.ts_0C1C33_17sp_medium
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                ),
                8.horizontalSpace,
                ImageRes.rightArrow.toImage
                  ..width = 20.w
                  ..height = 20.h,
              ],
            ),
          ),
        ),
      );

  Widget _buildNotFoundView() => Center(
        child: Container(
          constraints: BoxConstraints(minWidth: 220.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Styles.surface,
            border: Border.all(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
            borderRadius: BorderRadius.circular(Styles.radiusMedium.r),
          ),
          child: (logic.isSearchUser ? StrRes.noFoundUser : StrRes.noFoundGroup)
              .toText
            ..style = Styles.ts_8E9AB0_17sp
            ..textAlign = TextAlign.center,
        ),
      );
}
