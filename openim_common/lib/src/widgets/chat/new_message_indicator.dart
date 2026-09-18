import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

class NewMessageIndicator extends StatelessWidget {
  const NewMessageIndicator({
    Key? key,
    this.newMessageCount = 0,
    this.onTap,
  }) : super(key: key);
  final int newMessageCount;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          constraints: BoxConstraints(minHeight: Styles.controlHeight.h),
          decoration: BoxDecoration(
            color: Styles.surface,
            borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            border: Border.all(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 1.h),
                blurRadius: 4.r,
                color: Styles.ink.withValues(alpha: .06),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageRes.scrollDown.toImage
                ..width = 16.w
                ..height = 16.h,
              4.horizontalSpace,
              sprintf(StrRes.nMessage, [newMessageCount]).toText
                ..style = Styles.ts_0089FF_12sp,
            ],
          ),
        ),
      ),
    );
  }
}
