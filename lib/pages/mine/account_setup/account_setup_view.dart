import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'account_setup_logic.dart';

class AccountSetupPage extends StatelessWidget {
  final logic = Get.find<AccountSetupLogic>();

  AccountSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.accountSetup),
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
                  label: StrRes.blacklist,
                  onTap: logic.blacklist,
                ),
                _buildItemView(
                  label: StrRes.languageSetup,
                  value: logic.curLanguage.value,
                  onTap: logic.languageSetting,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 设置项以连续分组行呈现，并显示原有语言状态值。
  Widget _buildItemView({
    required String label,
    String? value,
    bool showDivider = true,
    Function()? onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 58.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: Styles.divider))
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: label.toText..style = Styles.ts_0C1C33_17sp,
                ),
                if (value != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 150.w),
                    child: value.toText
                      ..style = Styles.ts_8E9AB0_14sp
                      ..maxLines = 1
                      ..overflow = TextOverflow.ellipsis,
                  ),
                6.horizontalSpace,
                ImageRes.rightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
              ],
            ),
          ),
        ),
      );
}
