import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'language_setup_logic.dart';

class LanguageSetupPage extends StatelessWidget {
  final logic = Get.find<LanguageSetupLogic>();

  LanguageSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.languageSetup),
      backgroundColor: Styles.background,
      body: Obx(
        () => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Styles.surface,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: Styles.divider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildItemView(
                  label: StrRes.followSystem,
                  isChecked: logic.isFollowSystem.value,
                  onTap: () => logic.switchLanguage(0),
                ),
                _buildItemView(
                  label: StrRes.chinese,
                  isChecked: logic.isChinese.value,
                  onTap: () => logic.switchLanguage(1),
                ),
                _buildItemView(
                  label: StrRes.english,
                  isChecked: logic.isEnglish.value,
                  onTap: () => logic.switchLanguage(2),
                ),
                _buildItemView(
                  label: StrRes.traditionalChinese,
                  isChecked: logic.isTraditionalChinese.value,
                  onTap: () => logic.switchLanguage(3),
                ),
                _buildItemView(
                  label: StrRes.vietnamese,
                  isChecked: logic.isVietnamese.value,
                  onTap: () => logic.switchLanguage(4),
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 选中项使用浅红底、左侧识别线和现有勾选图标共同表达状态。
  Widget _buildItemView({
    required String label,
    bool isChecked = false,
    bool showDivider = true,
    Function()? onTap,
  }) =>
      Material(
        color: isChecked ? Styles.primaryContainer : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 60.h),
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: Styles.divider))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: isChecked ? 32.h : 0,
                  color: isChecked ? Styles.primary : Colors.transparent,
                ),
                12.horizontalSpace,
                Expanded(
                  child: label.toText
                    ..style = isChecked
                        ? Styles.ts_0C1C33_17sp_medium
                        : Styles.ts_0C1C33_17sp,
                ),
                if (isChecked)
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Styles.primary,
                      BlendMode.srcIn,
                    ),
                    child: ImageRes.checked.toImage
                      ..width = 24.w
                      ..height = 24.h,
                  ),
                16.horizontalSpace,
              ],
            ),
          ),
        ),
      );
}
