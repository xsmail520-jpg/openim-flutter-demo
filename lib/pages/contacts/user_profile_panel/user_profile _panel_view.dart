import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'user_profile _panel_logic.dart';

class UserProfilePanelPage extends StatelessWidget {
  final logic = Get.find<UserProfilePanelLogic>(tag: GetTags.userProfile);

  UserProfilePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: TitleBar.back(
          showUnderline: true,
          right: logic.isFriendship
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: logic.friendSetup,
                  child: SizedBox(
                    width: Styles.controlHeight,
                    height: Styles.controlHeight,
                    child: Center(
                      child: ImageRes.moreBlack.toImage
                        ..width = 24.w
                        ..height = 24.h,
                    ),
                  ),
                )
              : null,
        ),
        backgroundColor: Styles.background,
        body: SizedBox(
          height: 1.sh,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom:
                      ((logic.isFriendship || logic.allowSendMsgNotFriend) &&
                              !logic.isMyself)
                          ? 72 + MediaQuery.paddingOf(context).bottom
                          : 16,
                ),
                child: Column(
                  children: [
                    _buildBaseInfoView(),
                    if (logic.isGroupMemberPage) _buildEnterGroupMethodView(),
                    if (logic.isFriendship ||
                        logic.isMyself ||
                        logic.isGroupMemberPage &&
                            !logic.notAllowLookGroupMemberProfiles.value)
                      _buildItemView(
                        label: StrRes.personalInfo,
                        showRightArrow: true,
                        onTap: logic.viewPersonalInfo,
                      ),
                  ],
                ),
              ),
              if ((logic.isFriendship || logic.allowSendMsgNotFriend) &&
                  !logic.isMyself)
                _buildButtonGroup(),
            ],
          ),
        ),
      ),
    );
  }

  /// 头像、身份与加好友动作集中为资料页首屏主区域。
  Widget _buildBaseInfoView() => Container(
        constraints: BoxConstraints(minHeight: 112.h),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: const BoxDecoration(
          color: Styles.surface,
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
              url: logic.userInfo.value.faceURL,
              text: logic.userInfo.value.nickname,
              width: 64.w,
              height: 64.h,
              textStyle: Styles.ts_FFFFFF_17sp,
              enabledPreview: true,
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  logic.getShowName().toText
                    ..style = Styles.ts_0C1C33_20sp_semibold
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                  if (!logic.isGroupMemberPage ||
                      logic.isGroupMemberPage &&
                          !logic.notAllowAddGroupMemberFriend.value)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: (logic.userInfo.value.userID ?? '').toText
                        ..style = Styles.ts_8E9AB0_14sp
                        ..onTap = logic.copyID,
                    ),
                ],
              ),
            ),
            if (!logic.isMyself &&
                logic.isAllowAddFriend &&
                !logic.isFriendship &&
                (!logic.isGroupMemberPage ||
                    logic.forceCanAdd == true ||
                    logic.isGroupMemberPage &&
                        !logic.notAllowAddGroupMemberFriend.value))
              Material(
                color: Colors.transparent,
                child: Ink(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Styles.primary,
                    borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                  ),
                  child: InkWell(
                    onTap: logic.addFriend,
                    borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                      ),
                      child: Row(
                        children: [
                          ImageRes.addContacts.toImage
                            ..width = 20.w
                            ..height = 20.h
                            ..color = Styles.c_FFFFFF,
                          2.horizontalSpace,
                          StrRes.add.toText..style = Styles.ts_FFFFFF_14sp,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  /// 入群信息保持原字段顺序，以固定标签列和可换行值列展示。
  Widget _buildEnterGroupMethodView() {
    if (logic.joinGroupTime.value == 0 && logic.joinGroupMethod.value.isEmpty) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: const BoxDecoration(
        color: Styles.surface,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Styles.divider,
            width: Styles.dividerWidth,
          ),
        ),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        columnWidths: {0: FixedColumnWidth(100.w)},
        children: [
          if (logic.joinGroupTime.value > 0)
            _buildTabRowView(
              label: StrRes.joinGroupDate,
              value: DateUtil.formatDateMs(
                logic.joinGroupTime.value,
                format: DateFormats.zh_y_mo_d,
              ),
            ),
          if (logic.joinGroupMethod.value.isNotEmpty)
            _buildTabRowView(
              label: StrRes.joinGroupMethod,
              value: logic.joinGroupMethod.value,
            ),
        ],
      ),
    );
  }

  TableRow _buildTabRowView({
    required String label,
    String? value,
  }) =>
      TableRow(
        children: [
          TableCell(
            child: Container(
              constraints: BoxConstraints(minHeight: 48.h),
              alignment: Alignment.centerLeft,
              child: label.toText..style = Styles.ts_8E9AB0_16sp,
            ),
          ),
          TableCell(
            child: Container(
              constraints: BoxConstraints(minHeight: 48.h),
              alignment: Alignment.centerLeft,
              child: (value ?? '').toText..style = Styles.ts_0C1C33_17sp,
            ),
          ),
        ],
      );

  /// 资料入口沿用原状态和回调，改为带上下边界的连续列表行。
  Widget _buildItemView({
    required String label,
    String? value,
    bool addMargin = false,
    bool showSwitchButton = false,
    bool showRightArrow = false,
    bool switchOn = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) =>
      Container(
        margin: EdgeInsets.only(bottom: addMargin ? 12.h : 0),
        child: Ink(
          decoration: const BoxDecoration(
            color: Styles.surface,
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Styles.divider,
                width: Styles.dividerWidth,
              ),
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: 56.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  label.toText..style = Styles.ts_0C1C33_17sp,
                  const Spacer(),
                  if (showSwitchButton)
                    CupertinoSwitch(
                      value: switchOn,
                      activeColor: Styles.c_0089FF,
                      onChanged: onChanged,
                    ),
                  if (null != value)
                    value.toText..style = Styles.ts_0C1C33_17sp,
                  if (showRightArrow)
                    ImageRes.rightArrow.toImage
                      ..width = 24.w
                      ..height = 24.h,
                ],
              ),
            ),
          ),
        ),
      );

  /// 底部通话与消息操作改为固定白色命令栏，避免玻璃模糊遮挡正文。
  Widget _buildButtonGroup() => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SafeArea(
          top: false,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: const BoxDecoration(
              color: Styles.surface,
              border: BorderDirectional(
                top: BorderSide(
                  color: Styles.divider,
                  width: Styles.dividerWidth,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ImageTextButton.call(
                    onTap: logic.toCall,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ImageTextButton.message(
                    onTap: logic.toChat,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
