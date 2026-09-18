import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'contacts_logic.dart';

class ContactsPage extends StatelessWidget {
  final logic = Get.find<ContactsLogic>();

  ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Styles.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: TitleBar.contacts(
          onClickAddContacts: logic.addContacts,
        ),
        backgroundColor: Styles.background,
        body: Obx(
          () => RefreshIndicator(
            color: Styles.primary,
            onRefresh: logic.refreshFriends,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSearchEntry()),
                SliverToBoxAdapter(
                  child: _buildSection(
                    children: [
                      _buildItemView(
                        icon: _buildEntryIcon(Icons.person_add_alt_1_rounded),
                        label: StrRes.newFriend,
                        count: logic.friendApplicationCount,
                        onTap: logic.newFriend,
                      ),
                      _buildDivider(),
                      _buildItemView(
                        icon: _buildEntryIcon(
                          Icons.mark_unread_chat_alt_rounded,
                        ),
                        label: StrRes.newGroupRequest,
                        count: logic.groupApplicationCount,
                        onTap: logic.newGroup,
                      ),
                      _buildDivider(),
                      _buildItemView(
                        icon: _buildEntryIcon(Icons.groups_outlined),
                        label: StrRes.myGroup,
                        onTap: logic.myGroup,
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildFriendHeader(logic.friendList.length),
                ),
                if (logic.isFriendListLoading.value)
                  SliverToBoxAdapter(child: _buildLoadingState())
                else if (logic.friendList.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _buildFriendItem(logic.friendList[index]),
                      childCount: logic.friendList.length,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 首页搜索入口与消息页保持同一高度和垂直间距，切换 Tab 时不发生跳动。
  Widget _buildSearchEntry() => Container(
        color: Styles.primary,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
        child: Semantics(
          button: true,
          label: StrRes.search,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            child: InkWell(
              onTap: logic.searchContacts,
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: SearchBox(
                    height: Styles.controlHeight,
                    hintText: StrRes.search,
                    backgroundColor: Styles.surface,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// 联系入口按业务类别分区，区内保持连续列表与细分隔。
  Widget _buildSection({required List<Widget> children}) => Container(
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border(
            top: BorderSide(color: Styles.divider, width: Styles.dividerWidth),
          ),
        ),
        child: Column(children: children),
      );

  Widget _buildDivider() => Padding(
        padding: EdgeInsets.only(left: 64.w),
        child: const Divider(height: Styles.dividerWidth),
      );

  Widget _buildFriendHeader(int count) => Container(
        color: Styles.background,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Row(
          children: [
            StrRes.myFriend.toText..style = Styles.ts_0C1C33_17sp_semibold,
            8.horizontalSpace,
            '$count'.toText..style = Styles.ts_8E9AB0_14sp,
          ],
        ),
      );

  Widget _buildLoadingState() => Container(
        height: 96.h,
        color: Styles.surface,
        alignment: Alignment.center,
        child: SizedBox(
          width: 22.w,
          height: 22.h,
          child: const CircularProgressIndicator(
            color: Styles.primary,
            strokeWidth: 2,
          ),
        ),
      );

  Widget _buildEmptyState() => Container(
        height: 112.h,
        color: Styles.surface,
        alignment: Alignment.center,
        child: StrRes.noFriendYet.toText..style = Styles.ts_8E9AB0_14sp,
      );

  Widget _buildFriendItem(ISUserInfo info) => Ink(
        color: Styles.surface,
        child: InkWell(
          onTap: () => logic.viewFriendInfo(info),
          child: Container(
            constraints: BoxConstraints(minHeight: 64.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                AvatarView(
                  width: 42.w,
                  height: 42.h,
                  url: info.faceURL,
                  text: info.showName,
                ),
                12.horizontalSpace,
                Expanded(
                  child: info.showName.toText
                    ..style = Styles.ts_0C1C33_17sp_medium
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                ),
                ImageRes.rightArrow.toImage
                  ..width = 20.w
                  ..height = 20.h,
              ],
            ),
          ),
        ),
      );

  /// 通讯录入口使用同一套线性图标，避免旧位图在主题着色后出现杂色和方形底图。
  Widget _buildEntryIcon(IconData iconData) => Container(
        width: 36.w,
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Styles.primaryContainer,
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
        ),
        child: Icon(iconData, size: 21.w, color: Styles.primary),
      );

  Widget _buildItemView({
    required String label,
    Widget? icon,
    int count = 0,
    bool showRightArrow = true,
    double? height,
    Function()? onTap,
  }) =>
      Ink(
        color: Styles.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              minHeight: height ?? 56.h,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                if (null != icon) icon,
                12.horizontalSpace,
                label.toText..style = Styles.ts_0C1C33_17sp,
                const Spacer(),
                if (count > 0) UnreadCountView(count: count),
                4.horizontalSpace,
                if (showRightArrow)
                  ImageRes.rightArrow.toImage
                    ..width = 20.w
                    ..height = 20.h,
              ],
            ),
          ),
        ),
      );
}
