import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'group_manage_logic.dart';

class GroupManagePage extends StatelessWidget {
  final logic = Get.find<GroupManageLogic>();

  GroupManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.groupManage),
      backgroundColor: Styles.background,
      body: Obx(() => ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            children: [
              _buildSwitchEntry(
                title: '锁群（全员禁言）',
                subtitle: '开启后普通成员不能发送消息',
                value: logic.isGroupLocked,
                onChanged: logic.changeGroupLock,
              ),
              12.verticalSpace,
              _buildSwitchEntry(
                title: '群成员隐私保护',
                subtitle: '普通成员不能查看成员资料、人数或从群内添加好友',
                value: logic.privacyEnabled,
                onChanged: logic.changeGroupPrivacy,
              ),
              12.verticalSpace,
              if (logic.groupSetupLogic.isOwner) _buildTransferEntry(),
            ],
          )),
    );
  }

  /// 以单一高优先级操作行呈现群主转让入口，避免孤立的小卡片样式。
  Widget _buildTransferEntry() => Material(
        color: Styles.surface,
        borderRadius: BorderRadius.circular(6.r),
        child: InkWell(
          onTap: logic.transferGroupOwnerRight,
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            constraints: BoxConstraints(minHeight: 60.h),
            decoration: BoxDecoration(
              border: Border.all(color: Styles.divider),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Styles.primary,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(4.r),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: StrRes.transferGroupOwnerRight.toText
                    ..style = Styles.ts_0C1C33_17sp_medium,
                ),
                ImageRes.rightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
                12.horizontalSpace,
              ],
            ),
          ),
        ),
      );

  Widget _buildSwitchEntry({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Styles.surface,
          border: Border.all(color: Styles.divider),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title.toText..style = Styles.ts_0C1C33_17sp_medium,
                4.verticalSpace,
                subtitle.toText..style = Styles.ts_8E9AB0_14sp,
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: Styles.primary,
            onChanged: onChanged,
          ),
        ]),
      );
}
