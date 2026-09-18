import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'add_method_logic.dart';

class AddContactsMethodPage extends StatelessWidget {
  final logic = Get.find<AddContactsMethodLogic>();

  AddContactsMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.add, showUnderline: true),
      backgroundColor: Styles.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Container(
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
            children: [
              _buildItemView(
                icon: ImageRes.addFriendBlue,
                text: StrRes.addFriend,
                hintText: StrRes.addFriendHint,
                onTap: logic.addFriend,
              ),
              _buildItemView(
                icon: ImageRes.createGroupBlue,
                text: StrRes.createGroup,
                hintText: StrRes.createGroupHint,
                onTap: logic.createGroup,
              ),
              _buildItemView(
                icon: ImageRes.addGroupBLue,
                text: StrRes.addGroup,
                hintText: StrRes.addGroupHint,
                onTap: logic.addGroup,
                underline: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 添加方式合并为单一业务分区，通过图标底板、主副标题和箭头明确层级。
  Widget _buildItemView({
    required String icon,
    required String text,
    required String hintText,
    bool underline = true,
    Function()? onTap,
  }) =>
      Ink(
        color: Styles.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 76.h),
            padding: EdgeInsets.only(left: 16.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Styles.primaryContainer,
                    borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                  ),
                  child: icon.toImage
                    ..width = 24.w
                    ..height = 24.h
                    ..color = Styles.primary,
                ),
                12.horizontalSpace,
                Expanded(
                  child: Container(
                    decoration: underline
                        ? const BoxDecoration(
                            border: BorderDirectional(
                              bottom: BorderSide(
                                color: Styles.divider,
                                width: Styles.dividerWidth,
                              ),
                            ),
                          )
                        : null,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              text.toText..style = Styles.ts_0C1C33_17sp,
                              4.verticalSpace,
                              hintText.toText..style = Styles.ts_8E9AB0_12sp,
                            ],
                          ),
                        ),
                        ImageRes.rightArrow.toImage
                          ..width = 20.w
                          ..height = 20.h,
                        16.horizontalSpace,
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
