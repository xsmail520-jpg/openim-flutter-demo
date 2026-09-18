import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'send_verification_application_logic.dart';

class SendVerificationApplicationPage extends StatelessWidget {
  final logic = Get.find<SendVerificationApplicationLogic>();

  SendVerificationApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: TitleBar.back(
          title: logic.isEnterGroup
              ? StrRes.groupVerification
              : StrRes.friendVerification,
          showUnderline: true,
          right: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: logic.send,
            child: SizedBox(
              width: 44.w,
              height: 44.h,
              child: Center(
                child: StrRes.send.toText
                  ..style = Styles.ts_0089FF_17sp_semibold,
              ),
            ),
          ),
        ),
        backgroundColor: Styles.background,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                  child: (logic.isEnterGroup
                          ? StrRes.sendEnterGroupApplication
                          : StrRes.sendToBeFriendApplication)
                      .toText
                    ..style = Styles.ts_8E9AB0_14sp,
                ),
                Container(
                  constraints: BoxConstraints(minHeight: 148.h),
                  decoration: const BoxDecoration(
                    color: Styles.surface,
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: Styles.divider,
                        width: Styles.dividerWidth,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: TextField(
                    controller: logic.inputCtrl,
                    autofocus: true,
                    maxLines: 10,
                    maxLength: 20,
                    style: Styles.ts_0C1C33_17sp,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
