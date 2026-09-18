import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'personal_info_logic.dart';

class PersonalInfoPage extends StatelessWidget {
  final logic = Get.find<PersonalInfoLogic>();

  PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.personalInfo,
        showUnderline: true,
      ),
      backgroundColor: Styles.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Obx(
          () => Column(
            children: [
              _buildSectionView(
                children: [
                  _buildItemView(
                    label: StrRes.avatar,
                    isAvatar: true,
                    value: logic.nickname,
                    url: logic.faceURL,
                  ),
                  _buildItemView(label: StrRes.name, value: logic.nickname),
                  if (logic.personalIntro != null)
                    _buildItemView(
                      label: StrRes.personalIntro,
                      value: logic.personalIntro,
                    ),
                  _buildItemView(
                    label: StrRes.gender,
                    value: logic.isMale ? StrRes.man : StrRes.woman,
                  ),
                  _buildItemView(
                    label: StrRes.englishName,
                    value: logic.englishName,
                  ),
                  _buildItemView(label: StrRes.birthDay, value: logic.birth),
                ],
              ),
              12.verticalSpace,
              _buildSectionView(
                children: [
                  _buildItemView(
                    label: StrRes.mobile,
                    value: logic.phoneNumber,
                    onTap: logic.clickPhoneNumber,
                  ),
                  _buildItemView(
                    label: StrRes.email,
                    value: logic.email,
                    onTap: logic.clickEmail,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 资料字段按信息类别分组，组内使用连续表格式行与缩进分隔。
  Widget _buildSectionView({required List<Widget> children}) => Container(
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
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: const Divider(height: Styles.dividerWidth),
                ),
            ],
          ],
        ),
      );

  /// 固定标签列并约束长值换行，保证头像与可拨打字段仍使用原回调。
  Widget _buildItemView({
    required String label,
    String? value,
    String? url,
    bool isAvatar = false,
    Function()? onTap,
  }) =>
      Material(
        color: Styles.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: isAvatar ? 68.h : 56.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                SizedBox(
                  width: 104.w,
                  child: label.toText..style = Styles.ts_8E9AB0_16sp,
                ),
                if (null != value && !isAvatar)
                  Expanded(
                    child: value.toText
                      ..style = Styles.ts_0C1C33_17sp
                      ..textAlign = TextAlign.right,
                  ),
                if (isAvatar)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: AvatarView(
                        width: 42.w,
                        height: 42.h,
                        url: url,
                        text: value,
                        textStyle: Styles.ts_FFFFFF_12sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
