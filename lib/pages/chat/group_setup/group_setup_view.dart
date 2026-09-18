import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'group_setup_logic.dart';

class GroupSetupPage extends StatelessWidget {
  final logic = Get.find<GroupSetupLogic>();

  GroupSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.groupChatSetup),
      backgroundColor: Styles.background,
      body: Obx(() => SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 16.h, bottom: 32.h),
              child: Column(
                children: [
                  if (logic.isJoinedGroup.value) _buildBaseInfoView(),
                  if (logic.isJoinedGroup.value) 12.verticalSpace,
                  if (logic.isJoinedGroup.value)
                    _buildItemView(
                      text: '群公告（置顶）',
                      value: (logic.groupInfo.value.notification ?? '').isEmpty
                          ? '暂无公告'
                          : logic.groupInfo.value.notification,
                      showRightArrow: logic.isOwnerOrAdmin,
                      isTopRadius: true,
                      isBottomRadius: true,
                      onTap: logic.isOwnerOrAdmin
                          ? logic.editGroupAnnouncement
                          : null,
                    ),
                  if (logic.isJoinedGroup.value) 12.verticalSpace,
                  if (logic.isJoinedGroup.value)
                    _buildItemView(
                      text: StrRes.notDisturbMode,
                      switchOn: logic.isNotDisturb,
                      showSwitchButton: true,
                      onChanged: logic.setNotDisturb,
                      isTopRadius: true,
                      isBottomRadius: true,
                    ),
                  if (logic.isJoinedGroup.value) 12.verticalSpace,
                  if (logic.isJoinedGroup.value && logic.isOwnerOrAdmin)
                    _buildMemberView(),
                  if (logic.isOwnerOrAdmin)
                    _buildItemView(
                      text: StrRes.groupManage,
                      showRightArrow: true,
                      isTopRadius: true,
                      isBottomRadius: true,
                      onTap: logic.groupManage,
                    ),
                  12.verticalSpace,
                  if (!logic.isOwner)
                    _buildItemView(
                      text: logic.isJoinedGroup.value
                          ? StrRes.exitGroup
                          : StrRes.delete,
                      textStyle: Styles.ts_FF381F_17sp,
                      showRightArrow: true,
                      isTopRadius: true,
                      isBottomRadius: true,
                      onTap: logic.quitGroup,
                    ),
                  if (logic.isOwner)
                    _buildItemView(
                      text: StrRes.dismissGroup,
                      textStyle: Styles.ts_FF381F_17sp,
                      isTopRadius: true,
                      isBottomRadius: true,
                      showRightArrow: true,
                      onTap: logic.quitGroup,
                    ),
                ],
              ),
            ),
          )),
    );
  }

  /// 群身份区以红色识别线和细边框建立页面首要层级。
  Widget _buildBaseInfoView() => Container(
        constraints: BoxConstraints(minHeight: 84.h),
        padding: EdgeInsets.fromLTRB(0, 14.h, 14.w, 14.h),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Styles.primary,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(4.r),
                ),
              ),
            ),
            12.horizontalSpace,
            SizedBox(
              width: 50.h,
              height: 50.h,
              child: Stack(
                children: [
                  AvatarView(
                    width: 48.w,
                    height: 48.h,
                    url: logic.groupInfo.value.faceURL,
                    file: logic.avatar.value,
                    text: logic.groupInfo.value.groupName,
                    textStyle: Styles.ts_FFFFFF_14sp,
                    isGroup: true,
                    onTap:
                        logic.isOwnerOrAdmin ? logic.modifyGroupAvatar : null,
                  ),
                  if (logic.isOwnerOrAdmin)
                    Align(
                        alignment: Alignment.bottomRight,
                        child: ImageRes.editAvatar.toImage
                          ..width = 14.w
                          ..height = 14.h)
                ],
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: logic.isOwnerOrAdmin
                        ? () => logic.modifyGroupName(
                            logic.conversationInfo.value.faceURL)
                        : null,
                    child: Row(
                      children: [
                        ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 200.w),
                            child:
                                (logic.groupInfo.value.groupName ?? '').toText
                                  ..style = Styles.ts_0C1C33_17sp_medium
                                  ..maxLines = 1
                                  ..overflow = TextOverflow.ellipsis),
                        if (logic.isOwnerOrAdmin)
                          '(${logic.groupInfo.value.memberCount ?? 0})'.toText
                            ..style = Styles.ts_0C1C33_17sp,
                        6.horizontalSpace,
                        if (logic.isOwnerOrAdmin)
                          ImageRes.editName.toImage
                            ..width = 12.w
                            ..height = 12.h,
                      ],
                    ),
                  ),
                  4.verticalSpace,
                  logic.groupInfo.value.groupID.toText
                    ..style = Styles.ts_8E9AB0_14sp
                    ..onTap = logic.copyGroupID,
                ],
              ),
            ),
          ],
        ),
      );

  /// 成员头像、增删入口和查看全部入口组成同一连续分区。
  Widget _buildMemberView() => Container(
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: Column(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logic.length(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 68.w / 78.h,
              ),
              itemBuilder: (BuildContext context, int index) {
                return logic.itemBuilder(
                  index: index,
                  builder: (info) => Column(
                    children: [
                      SizedBox(
                        width: 58.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AvatarView(
                              width: 48.w,
                              height: 48.h,
                              url: info.faceURL,
                              text: info.nickname,
                              textStyle: Styles.ts_FFFFFF_14sp,
                              onTap: () => logic.viewMemberInfo(info),
                            ),
                            if (logic.groupInfo.value.ownerUserID ==
                                info.userID)
                              Positioned(
                                bottom: 0.h,
                                child: Container(
                                  width: 52.h,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Styles.primaryContainer,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: StrRes.groupOwner.toText
                                    ..style = Styles.ts_0089FF_10sp_semibold
                                    ..maxLines = 1
                                    ..overflow = TextOverflow.ellipsis,
                                ),
                              )
                          ],
                        ),
                      ),
                      2.verticalSpace,
                      (info.nickname ?? '').toText
                        ..style = Styles.ts_8E9AB0_10sp
                        ..maxLines = 1
                        ..overflow = TextOverflow.ellipsis,
                    ],
                  ),
                  addButton: () => GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: logic.addMember,
                    child: SizedBox(
                      width: 64.w,
                      height: 72.h,
                      child: Column(
                        children: [
                          ImageRes.addMember.toImage
                            ..width = 48.w
                            ..height = 48.h,
                          StrRes.addMember.toText
                            ..style = Styles.ts_8E9AB0_10sp,
                        ],
                      ),
                    ),
                  ),
                  delButton: () => GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: logic.removeMember,
                    child: SizedBox(
                      width: 64.w,
                      height: 72.h,
                      child: Column(
                        children: [
                          ImageRes.delMember.toImage
                            ..width = 48.w
                            ..height = 48.h,
                          StrRes.delMember.toText
                            ..style = Styles.ts_8E9AB0_10sp,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              color: Styles.divider,
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: logic.viewGroupMembers,
              child: Container(
                padding: EdgeInsets.only(left: 12.w, right: 16.w),
                constraints: BoxConstraints(minHeight: 54.h),
                child: Row(
                  children: [
                    sprintf(StrRes.viewAllGroupMembers,
                        [logic.groupInfo.value.memberCount]).toText
                      ..style = Styles.ts_0C1C33_17sp,
                    const Spacer(),
                    ImageRes.rightArrow.toImage
                      ..width = 24.w
                      ..height = 24.h,
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildItemView({
    required String text,
    TextStyle? textStyle,
    String? value,
    bool switchOn = false,
    bool isTopRadius = false,
    bool isBottomRadius = false,
    bool showRightArrow = false,
    bool showSwitchButton = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          constraints: BoxConstraints(minHeight: 56.h),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Styles.surface,
            border: Border.all(
              color: textStyle == Styles.ts_FF381F_17sp
                  ? Styles.danger.withValues(alpha: .55)
                  : Styles.divider,
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(isTopRadius ? 6.r : 0),
              topLeft: Radius.circular(isTopRadius ? 6.r : 0),
              bottomLeft: Radius.circular(isBottomRadius ? 6.r : 0),
              bottomRight: Radius.circular(isBottomRadius ? 6.r : 0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                  child: text.toText
                    ..style = textStyle ?? Styles.ts_0C1C33_17sp
                    ..maxLines = 1),
              if (null != value)
                value.toText
                  ..style = Styles.ts_8E9AB0_14sp
                  ..maxLines = 1
                  ..overflow = TextOverflow.ellipsis,
              if (showSwitchButton)
                CupertinoSwitch(
                  value: switchOn,
                  activeColor: Styles.c_0089FF,
                  onChanged: onChanged,
                ),
              if (showRightArrow)
                ImageRes.rightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
            ],
          ),
        ),
      );
}
