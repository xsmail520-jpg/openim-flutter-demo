import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'friend_setup_logic.dart';

class FriendSetupPage extends StatelessWidget {
  final logic = Get.find<FriendSetupLogic>();

  FriendSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.friendSetup,
        showUnderline: true,
      ),
      backgroundColor: Styles.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          children: [
            _buildSection(
              children: [
                _buildItemView(
                  label: StrRes.setupRemark,
                  showRightArrow: true,
                  showDivider: true,
                  onTap: logic.setFriendRemark,
                ),
                _buildItemView(
                  label: StrRes.recommendToFriend,
                  showRightArrow: true,
                  onTap: logic.recommendToFriend,
                ),
              ],
            ),
            12.verticalSpace,
            _buildSection(
              children: [
                Obx(
                  () => _buildItemView(
                    label: StrRes.addToBlacklist,
                    showSwitchButton: true,
                    switchOn:
                        logic.userProfilesLogic.userInfo.value.isBlacklist ==
                            true,
                    onChanged: (_) => logic.toggleBlacklist(),
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            _buildSection(
              children: [
                _buildItemView(
                  isDelFriendButton: true,
                  onTap: logic.deleteFromFriendList,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 设置项按业务关系分区，区内使用连续列表和水平边界。
  Widget _buildSection({required List<Widget> children}) => Container(
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Column(children: children),
      );

  /// 每行保证 56dp 操作区域，危险操作只通过语义色区分而不改变回调。
  Widget _buildItemView({
    String? label,
    bool showRightArrow = false,
    bool showSwitchButton = false,
    bool showDivider = false,
    bool switchOn = false,
    bool isDelFriendButton = false,
    ValueChanged<bool>? onChanged,
    Function()? onTap,
  }) =>
      Material(
        color: Styles.surface,
        child: Ink(
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: BoxConstraints(minHeight: 56.h),
              alignment: isDelFriendButton ? Alignment.center : null,
              margin: EdgeInsets.only(left: isDelFriendButton ? 0 : 16.w),
              padding: EdgeInsets.only(
                left: isDelFriendButton ? 16.w : 0,
                right: 16.w,
              ),
              decoration: BoxDecoration(
                border: showDivider
                    ? const BorderDirectional(
                        bottom: BorderSide(
                          color: Styles.divider,
                          width: Styles.dividerWidth,
                        ),
                      )
                    : null,
              ),
              child: isDelFriendButton
                  ? (StrRes.unfriend.toText..style = Styles.ts_FF381F_17sp)
                  : Row(
                      children: [
                        (label ?? '').toText..style = Styles.ts_0C1C33_17sp,
                        const Spacer(),
                        if (showRightArrow)
                          ImageRes.rightArrow.toImage
                            ..width = 24.w
                            ..height = 24.h,
                        if (showSwitchButton)
                          CupertinoSwitch(
                            value: switchOn,
                            onChanged: onChanged,
                            activeColor: Styles.primary,
                          ),
                      ],
                    ),
            ),
          ),
        ),
      );
}
