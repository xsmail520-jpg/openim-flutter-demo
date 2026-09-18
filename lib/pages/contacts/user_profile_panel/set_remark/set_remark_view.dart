import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'set_remark_logic.dart';

class SetFriendRemarkPage extends StatelessWidget {
  final logic = Get.find<SetFriendRemarkLogic>();

  SetFriendRemarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.remark,
        showUnderline: true,
        right: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: logic.save,
          child: SizedBox(
            width: 44.w,
            height: 44.h,
            child: Center(
              child: StrRes.save.toText..style = Styles.ts_0089FF_17sp_semibold,
            ),
          ),
        ),
      ),
      backgroundColor: Styles.background,
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 48.h,
            margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            decoration: BoxDecoration(
              color: Styles.surface,
              border: Border.all(
                color: Styles.divider,
                width: Styles.dividerWidth,
              ),
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            ),
            child: TextField(
              controller: logic.inputCtrl,
              style: Styles.ts_0C1C33_17sp,
              autofocus: true,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 14.w,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
