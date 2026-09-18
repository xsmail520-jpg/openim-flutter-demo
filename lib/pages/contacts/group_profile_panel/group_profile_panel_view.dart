import 'dart:math';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'group_profile_panel_logic.dart';

class GroupProfilePanelPage extends StatelessWidget {
  final logic = Get.find<GroupProfilePanelLogic>();

  GroupProfilePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(showUnderline: true),
      backgroundColor: Styles.background,
      body: Obx(() => Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Column(
                    children: [
                      _buildBaseInfo(),
                      if (logic.members.isNotEmpty) ...[
                        12.verticalSpace,
                        _buildGroupMemberList(),
                      ],
                      12.verticalSpace,
                      _buildGroupIDRow(),
                    ],
                  ),
                ),
              ),
              _buildActionBar(),
            ],
          )),
    );
  }

  /// 群资料头部突出头像与群名，创建时间降为辅助信息。
  Widget _buildBaseInfo() => Container(
        constraints: BoxConstraints(minHeight: 92.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            AvatarView(
              width: 56.w,
              height: 56.h,
              url: logic.groupInfo.value.faceURL,
              text: logic.groupInfo.value.groupName,
              isGroup: true,
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (logic.groupInfo.value.groupName ?? '').toText
                    ..style = Styles.ts_0C1C33_17sp_semibold
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                  6.verticalSpace,
                  Row(
                    children: [
                      ImageRes.createGroupTime.toImage
                        ..width = 12.w
                        ..height = 12.h,
                      6.horizontalSpace,
                      DateUtil.formatDateMs(
                        (logic.groupInfo.value.createTime ?? 0),
                        format: IMUtils.getTimeFormat1(),
                      ).toText
                        ..style = Styles.ts_8E9AB0_14sp,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// 成员概览通过独立表头和头像带分层，成员上限与“更多”判断保持原样。
  Widget _buildGroupMemberList() => Container(
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(minHeight: 44.h),
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
                  StrRes.groupMember.toText
                    ..style = Styles.ts_0C1C33_17sp_semibold,
                  const Spacer(),
                  sprintf(
                    StrRes.nPerson,
                    [logic.groupInfo.value.memberCount],
                  ).toText
                    ..style = Styles.ts_8E9AB0_14sp,
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6.w,
                  childAspectRatio: 1,
                ),
                itemCount: min(logic.members.length, 7),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  final member = logic.members.elementAt(index);
                  if (index == 6 && logic.members.length != 7) {
                    return ImageRes.moreMembers.toImage
                      ..width = 44.w
                      ..height = 44.h;
                  }
                  return AvatarView(
                    width: 44.w,
                    height: 44.h,
                    text: member.nickname,
                    url: member.faceURL,
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildGroupIDRow() => Container(
        constraints: BoxConstraints(minHeight: 56.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            StrRes.groupID.toText..style = Styles.ts_8E9AB0_17sp,
            16.horizontalSpace,
            Expanded(
              child: logic.groupInfo.value.groupID.toText
                ..style = Styles.ts_0C1C33_17sp
                ..maxLines = 1
                ..overflow = TextOverflow.ellipsis
                ..textAlign = TextAlign.right,
            ),
          ],
        ),
      );

  Widget _buildActionBar() => SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
          decoration: const BoxDecoration(
            color: Styles.surface,
            border: BorderDirectional(
              top: BorderSide(
                color: Styles.divider,
                width: Styles.dividerWidth,
              ),
            ),
          ),
          child: Button(
            text: logic.isJoined.value ? StrRes.enterGroup : StrRes.applyJoin,
            onTap: logic.enterGroup,
          ),
        ),
      );
}
