import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'chat_setup_logic.dart';

class ChatSetupPage extends StatelessWidget {
  final logic = Get.find<ChatSetupLogic>();

  ChatSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(),
      backgroundColor: Styles.background,
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Column(
            children: [
              _buildBaseInfoView(),
              12.verticalSpace,
              _buildSwitchItem(
                text: StrRes.notDisturbMode,
                value: logic.isNotDisturb,
                onChanged: logic.setNotDisturb,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 将成员资料与建群入口组织为同一条连续操作栏，突出当前会话对象。
  Widget _buildBaseInfoView() => Container(
        constraints: BoxConstraints(minHeight: 76.h),
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
            Expanded(
              child: InkWell(
                onTap: logic.viewUserInfo,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  child: Row(
                    children: [
                      AvatarView(
                        width: 48.w,
                        height: 48.h,
                        text: logic.conversationInfo.value.showName,
                        url: logic.conversationInfo.value.faceURL,
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child:
                            (logic.conversationInfo.value.showName ?? '').toText
                              ..style = Styles.ts_0C1C33_17sp_medium
                              ..maxLines = 1
                              ..overflow = TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 44.h, color: Styles.divider),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: logic.createGroup,
                borderRadius: BorderRadius.circular(4.r),
                child: SizedBox(
                  width: 68.w,
                  height: 68.h,
                  child: Center(
                    child: ImageRes.addFriendTobeGroup.toImage
                      ..width = 44.w
                      ..height = 44.h,
                  ),
                ),
              ),
            ),
            4.horizontalSpace,
          ],
        ),
      );

  Widget _buildSwitchItem({
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Container(
        constraints: BoxConstraints(minHeight: 60.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: Row(
          children: [
            Expanded(child: text.toText..style = Styles.ts_0C1C33_17sp),
            Switch(
              value: value,
              activeColor: Styles.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      );
}
