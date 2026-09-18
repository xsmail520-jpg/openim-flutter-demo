import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatDisableInputBox extends StatelessWidget {
  const ChatDisableInputBox({Key? key, this.type = 0}) : super(key: key);

  final int type;

  @override
  Widget build(BuildContext context) {
    return type == 0
        ? Container(
            height: 56.h,
            decoration: const BoxDecoration(
              color: Styles.background,
              border: Border(
                top: BorderSide(
                  color: Styles.divider,
                  width: Styles.dividerWidth,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageRes.warn.toImage
                  ..width = 14.w
                  ..height = 14.h,
                6.horizontalSpace,
                StrRes.notSendMessageNotInGroup.toText
                  ..style = Styles.ts_8E9AB0_14sp,
              ],
            ),
          )
        : Container();
  }
}
