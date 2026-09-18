import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'edit_name_logic.dart';

class EditGroupNamePage extends StatelessWidget {
  final logic = Get.find<EditGroupNameLogic>();

  EditGroupNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (logic.type == EditNameType.groupNickname) {
      return Scaffold(
        appBar: TitleBar.back(),
        backgroundColor: Styles.background,
        body: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeading(),
                12.verticalSpace,
                _buildAvatarInput(),
                const Spacer(),
                Button(
                  height: 48.h,
                  text: StrRes.save,
                  onTap: logic.save,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: TitleBar.back(
        title: logic.title,
        right: StrRes.save.toText
          ..style = Styles.ts_0089FF_17sp_medium
          ..onTap = logic.save,
      ),
      backgroundColor: Styles.background,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
        child: _buildPlainInput(),
      ),
    );
  }

  /// 以克制的文电标题区承载原有标题与填写提示。
  Widget _buildHeading() => Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: Styles.surface,
          border: Border(
            left: BorderSide(color: Styles.primary, width: 4.w),
            top: BorderSide(color: Styles.divider),
            right: BorderSide(color: Styles.divider),
            bottom: BorderSide(color: Styles.divider),
          ),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StrRes.editGroupName.toText..style = Styles.ts_0C1C33_20sp_semibold,
            6.verticalSpace,
            StrRes.editGroupTips.toText..style = Styles.ts_8E9AB0_15sp,
          ],
        ),
      );

  /// 将群头像与名称输入合并成一条紧凑、可扫描的编辑行。
  Widget _buildAvatarInput() => Container(
        constraints: BoxConstraints(minHeight: 76.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: Row(
          children: [
            AvatarView(
              width: 48.w,
              height: 48.h,
              url: logic.faceUrl,
              isGroup: true,
            ),
            12.horizontalSpace,
            Expanded(child: _buildTextField()),
          ],
        ),
      );

  /// 为普通名称编辑提供独立白色输入面板，保留原提交入口。
  Widget _buildPlainInput() => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: _buildTextField(),
      );

  Widget _buildTextField() => TextField(
        controller: logic.inputCtrl,
        style: Styles.ts_0C1C33_17sp,
        autofocus: true,
        inputFormatters: [
          LengthLimitingTextInputFormatter(
            logic.type == EditNameType.groupAnnouncement ? 500 : 16,
          )
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: Styles.c_F8F9FA,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 12.w,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: Styles.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
            borderSide: BorderSide(color: Styles.primary),
          ),
        ),
      );
}
