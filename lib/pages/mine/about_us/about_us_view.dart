import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'about_us_logic.dart';

class AboutUsPage extends StatelessWidget {
  final logic = Get.find<AboutUsLogic>();

  AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.aboutUs),
      backgroundColor: Styles.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Column(
          children: [
            _buildIdentityHeader(),
            12.verticalSpace,
            _buildActionList(),
          ],
        ),
      ),
    );
  }

  /// 品牌与版本信息集中在文档式页首，版本复制行为保持不变。
  Widget _buildIdentityHeader() => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: Column(
          children: [
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: Styles.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
              ),
            ),
            22.verticalSpace,
            ImageRes.splashLogo.toImage
              ..width = 64.w
              ..height = 64.w,
            10.verticalSpace,
            Obx(
              () => '${logic.displayVersion}'.toText
                ..style = Styles.ts_0C1C33_14sp_medium
                ..onTap = logic.copyVersion,
            ),
            20.verticalSpace,
          ],
        ),
      );

  /// 更新与日志操作以连续列表呈现，减少多层卡片和阴影。
  Widget _buildActionList() => Container(
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: Column(
          children: [
            _buildAction(StrRes.checkNewVersion, logic.checkUpdate),
            _buildAction(
              StrRes.uploadErrorLog,
              _showDiagnosisSheet,
              showDivider: false,
            ),
          ],
        ),
      );

  Widget _buildAction(
    String text,
    Function() onTap, {
    bool showDivider = true,
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
                  child: text.toText..style = Styles.ts_0C1C33_17sp,
                ),
                ImageRes.rightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
              ],
            ),
          ),
        ),
      );

  void _showDiagnosisSheet() {
    showCupertinoModalPopup(
      context: Get.context!,
      builder: (context) => CupertinoActionSheet(
        title: const Text('问题诊断'),
        message: const Text('诊断信息仅用于协助排查使用问题，不包含聊天内容。'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              logic.uploadLogs(1000);
            },
            child: Text(StrRes.uploadLogWithLine),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              logic.uploadLogs();
            },
            child: const Text('提交完整的诊断信息'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(StrRes.cancel),
        ),
      ),
    );
  }
}
