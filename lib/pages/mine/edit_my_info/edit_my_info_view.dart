import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'edit_my_info_logic.dart';

class EditMyInfoPage extends StatelessWidget {
  static const _brandRed = Color(0xFF9E1B22);
  static const _ink = Color(0xFF172033);
  static const _pageBackground = Color(0xFFF4F6F8);
  static const _border = Color(0xFFD8DDE4);
  static const _muted = Color(0xFF6B7280);

  final logic = Get.find<EditMyInfoLogic>();

  EditMyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: TitleBar.back(
          title: logic.title,
          backgroundColor: Colors.white,
          backIconColor: _ink,
          showUnderline: true,
          titleStyle: TextStyle(
              color: _ink, fontSize: 17.sp, fontWeight: FontWeight.w600),
          right: _buildSaveButton(),
        ),
        backgroundColor: _pageBackground,
        body: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                logic.title ?? '',
                style: TextStyle(
                    color: _muted,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500),
              ),
              8.verticalSpace,
              TextField(
                controller: logic.inputCtrl,
                style: TextStyle(color: _ink, fontSize: 16.sp),
                autofocus: true,
                cursorColor: _brandRed,
                keyboardType: logic.keyboardType,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(logic.maxLength)
                ],
                onSubmitted: (_) => logic.save(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.r),
                    borderSide: const BorderSide(color: _brandRed, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 保存入口采用紧凑的文字按钮，避免弱化标题层级。
  Widget _buildSaveButton() => Semantics(
        button: true,
        label: StrRes.save,
        child: InkWell(
          onTap: logic.save,
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            alignment: Alignment.center,
            child: Text(
              StrRes.save,
              style: TextStyle(
                  color: _brandRed,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
}
