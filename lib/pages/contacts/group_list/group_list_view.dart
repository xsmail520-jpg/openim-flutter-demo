import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import 'group_list_logic.dart';

class GroupListPage extends StatelessWidget {
  GroupListPage({super.key});

  final logic = Get.find<GroupListLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.myGroup, showUnderline: true),
      backgroundColor: Styles.background,
      body: Obx(
        () => SmartRefresher(
          controller: logic.refreshController,
          header: IMViews.buildHeader(30),
          footer: IMViews.buildFooter(),
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: logic.refreshGroups,
          onLoading: logic.loadMoreGroups,
          child: logic.isInitialLoading.value
              ? _buildLoadingState()
              : logic.groupList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: logic.groupList.length,
                      itemBuilder: (_, index) =>
                          _buildItemView(logic.groupList[index]),
                    ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 210.h),
          Center(
            child: SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(
                color: Styles.primary,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      );

  Widget _buildEmptyState() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180.h),
          Center(
            child: Column(
              children: [
                Icon(Icons.groups_outlined, size: 40.w, color: Styles.muted),
                12.verticalSpace,
                StrRes.noGroupYet.toText..style = Styles.ts_8E9AB0_14sp,
              ],
            ),
          ),
        ],
      );

  Widget _buildItemView(GroupListItem item) {
    final info = item.info;
    return Ink(
      color: Styles.surface,
      child: InkWell(
        onTap: () => logic.toGroupChat(info),
        child: Container(
          constraints: BoxConstraints(minHeight: 72.h),
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
                width: 44.w,
                height: 44.h,
                url: info.faceURL,
                text: info.groupName,
                isGroup: true,
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: (info.groupName ?? '').toText
                            ..style = Styles.ts_0C1C33_17sp_medium
                            ..maxLines = 1
                            ..overflow = TextOverflow.ellipsis,
                        ),
                        8.horizontalSpace,
                        _buildRoleBadge(item.roleLevel),
                      ],
                    ),
                    5.verticalSpace,
                    sprintf(StrRes.nPerson, [info.memberCount]).toText
                      ..style = Styles.ts_8E9AB0_14sp,
                  ],
                ),
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
  }

  Widget _buildRoleBadge(int roleLevel) {
    late final String label;
    late final IconData icon;
    late final Color foreground;
    late final Color background;
    late final Color border;

    if (roleLevel == GroupRoleLevel.owner) {
      label = StrRes.groupOwner;
      icon = Icons.verified_user_rounded;
      foreground = Styles.primary;
      background = Styles.primaryContainer;
      border = Styles.primary.withValues(alpha: .18);
    } else if (roleLevel == GroupRoleLevel.admin) {
      label = StrRes.groupAdmin;
      icon = Icons.admin_panel_settings_rounded;
      foreground = Styles.gold;
      background = Styles.gold.withValues(alpha: .10);
      border = Styles.gold.withValues(alpha: .24);
    } else {
      label = StrRes.members;
      icon = Icons.person_outline_rounded;
      foreground = Styles.muted;
      background = Styles.surface;
      border = Styles.divider;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border, width: Styles.dividerWidth),
        borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: foreground),
          3.horizontalSpace,
          label.toText
            ..style = TextStyle(
              color: foreground,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
        ],
      ),
    );
  }
}
