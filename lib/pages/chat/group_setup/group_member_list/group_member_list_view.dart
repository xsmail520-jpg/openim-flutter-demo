import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import 'group_member_list_logic.dart';

class GroupMemberListPage extends StatelessWidget {
  final logic = Get.find<GroupMemberListLogic>(
    tag: (Get.arguments['opType'] as GroupMemberOpType).name,
  );

  GroupMemberListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: TitleBar.back(
          title: logic.opType == GroupMemberOpType.del
              ? StrRes.removeGroupMember
              : StrRes.groupMember,
          right: logic.opType == GroupMemberOpType.view
              ? PopButton(
                  popCtrl: logic.poController,
                  horizontalMargin: 1.w,
                  menus: [
                    PopMenuInfo(
                      text: StrRes.addMember,
                      onTap: logic.addMember,
                    ),
                    if (logic.isOwnerOrAdmin)
                      PopMenuInfo(
                        text: StrRes.delMember,
                        onTap: logic.delMember,
                      ),
                  ],
                  child: ImageRes.moreBlack.toImage
                    ..width = 28.w
                    ..height = 28.h,
                )
              : null,
        ),
        backgroundColor: Styles.background,
        body: Column(
          children: [
            _buildSearchCommand(),
            if (logic.opType == GroupMemberOpType.at && logic.isOwnerOrAdmin)
              _buildEveryoneEntry(),
            Expanded(child: _buildMemberList()),
            if (logic.isMultiSelMode) _buildCheckedConfirmView(),
          ],
        ),
      ),
    );
  }

  /// 搜索入口固定为页面级命令区，与成员数据列表分层呈现。
  Widget _buildSearchCommand() => Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: Styles.surface,
          border: Border(bottom: BorderSide(color: Styles.divider)),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: logic.search,
          child: const SearchBox(),
        ),
      );

  /// “所有人”保持为与普通成员一致的连续列表行，便于快速选择。
  Widget _buildEveryoneEntry() => Material(
        color: Styles.surface,
        child: InkWell(
          onTap: logic.selectEveryone,
          child: Container(
            constraints: BoxConstraints(minHeight: 64.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Styles.primaryContainer.withValues(alpha: .45),
              border: Border(bottom: BorderSide(color: Styles.divider)),
            ),
            child: Row(
              children: [
                AvatarView(
                  width: 44.w,
                  height: 44.h,
                  text: '@',
                  textStyle: Styles.ts_FFFFFF_21sp,
                ),
                12.horizontalSpace,
                Expanded(
                  child: StrRes.everyone.toText
                    ..style = Styles.ts_0C1C33_17sp_medium,
                ),
                Container(width: 3.w, height: 28.h, color: Styles.primary),
              ],
            ),
          ),
        ),
      );

  /// 成员内容区使用无阴影白色连续列表，保留原刷新和分页行为。
  Widget _buildMemberList() => Container(
        color: Styles.surface,
        child: SmartRefresher(
          controller: logic.controller,
          onLoading: logic.onLoad,
          enablePullDown: false,
          enablePullUp: true,
          header: IMViews.buildHeader(),
          footer: IMViews.buildFooter(),
          child: ListView.builder(
            itemCount: logic.memberList.length,
            itemBuilder: (_, index) => Obx(
              () => _buildItemView(logic.memberList[index]),
            ),
          ),
        ),
      );

  Widget _buildItemView(GroupMembersInfo membersInfo) =>
      logic.hiddenMember(membersInfo)
          ? const SizedBox()
          : Material(
              color: Styles.surface,
              child: InkWell(
                onTap: () => logic.clickMember(membersInfo),
                child: Container(
                  constraints: BoxConstraints(minHeight: 68.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Styles.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (logic.isMultiSelMode)
                        Padding(
                          padding: EdgeInsets.only(right: 14.w),
                          child: ChatRadio(
                            checked: logic.isChecked(membersInfo),
                          ),
                        ),
                      AvatarView(
                        width: 44.w,
                        height: 44.h,
                        url: membersInfo.faceURL,
                        text: membersInfo.nickname,
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: (membersInfo.nickname ?? '').toText
                          ..style = Styles.ts_0C1C33_17sp
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis,
                      ),
                      if (membersInfo.roleLevel == GroupRoleLevel.owner)
                        _buildRoleLabel(StrRes.groupOwner),
                      if (membersInfo.roleLevel == GroupRoleLevel.admin)
                        _buildRoleLabel(StrRes.groupAdmin),
                    ],
                  ),
                ),
              ),
            );

  /// 群角色采用轻量标签，不与昵称争夺主视觉层级。
  Widget _buildRoleLabel(String text) => Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Styles.primaryContainer,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: text.toText..style = Styles.ts_0089FF_12sp,
      );

  /// 多选操作固定在底部，细分隔替代悬浮阴影并保留原确认信息。
  Widget _buildCheckedConfirmView() => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(minHeight: 72.h),
          decoration: BoxDecoration(
            color: Styles.surface,
            border: Border(top: BorderSide(color: Styles.divider)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => Get.bottomSheet(
                    SelectedMemberListView(),
                    isScrollControlled: true,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          sprintf(
                            StrRes.selectedPeopleCount,
                            [logic.checkedList.length],
                          ).toText
                            ..style = Styles.ts_0089FF_14sp_medium,
                          ImageRes.expandUpArrow.toImage
                            ..width = 24.w
                            ..height = 24.h,
                        ],
                      ),
                      if (logic.checkedList.isNotEmpty) 3.verticalSpace,
                      logic.checkedList
                          .map((e) => e.nickname ?? '')
                          .join('、')
                          .toText
                        ..style = Styles.ts_8E9AB0_14sp
                        ..maxLines = 1
                        ..overflow = TextOverflow.ellipsis,
                    ],
                  ),
                ),
              ),
              12.horizontalSpace,
              Button(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                text: sprintf(StrRes.confirmSelectedPeople, [
                  logic.checkedList.length,
                  logic.maxLength,
                ]),
                textStyle: Styles.ts_FFFFFF_14sp_medium,
                onTap: logic.confirmSelectedMember,
              ),
            ],
          ),
        ),
      );
}

class SelectedMemberListView extends StatelessWidget {
  SelectedMemberListView({super.key});

  final logic = Get.find<GroupMemberListLogic>(
    tag: (Get.arguments['opType'] as GroupMemberOpType).name,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 548.h),
      decoration: BoxDecoration(
        color: Styles.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6.r),
          topRight: Radius.circular(6.r),
        ),
      ),
      child: Obx(
        () => Column(
          children: [
            Container(height: 3.h, color: Styles.primary),
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: logic.checkedList.length,
                itemBuilder: (_, index) =>
                    _buildItemView(logic.checkedList[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 底部抽屉标题与确认操作保持固定，便于长名单浏览。
  Widget _buildHeader() => Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Styles.divider)),
        ),
        child: Row(
          children: [
            sprintf(
              StrRes.selectedPeopleCount,
              [logic.checkedList.length],
            ).toText
              ..style = Styles.ts_0C1C33_17sp_medium,
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Get.back(),
              child: Container(
                constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
                alignment: Alignment.centerRight,
                child: StrRes.confirm.toText
                  ..style = Styles.ts_0089FF_17sp_medium,
              ),
            ),
          ],
        ),
      );

  Widget _buildItemView(GroupMembersInfo membersInfo) => Container(
        constraints: BoxConstraints(minHeight: 68.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Styles.surface,
          border: Border(bottom: BorderSide(color: Styles.divider)),
        ),
        child: Row(
          children: [
            AvatarView(
              width: 44.w,
              height: 44.h,
              url: membersInfo.faceURL,
              text: membersInfo.nickname,
            ),
            12.horizontalSpace,
            Expanded(
              child: (membersInfo.nickname ?? '').toText
                ..style = Styles.ts_0C1C33_17sp
                ..maxLines = 1
                ..overflow = TextOverflow.ellipsis,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => logic.removeSelectedMember(membersInfo),
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  constraints: BoxConstraints(minWidth: 52.w, minHeight: 36.h),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Styles.danger),
                  ),
                  child: StrRes.remove.toText..style = Styles.ts_FF381F_14sp,
                ),
              ),
            ),
          ],
        ),
      );
}
