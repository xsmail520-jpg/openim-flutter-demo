import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatNoticeView extends StatelessWidget {
  const ChatNoticeView({
    Key? key,
    required this.isISend,
    required this.content,
  }) : super(key: key);
  final bool isISend;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Styles.surface,
        border: Border.all(
          color: Styles.divider,
          width: Styles.dividerWidth,
        ),
        borderRadius: borderRadius(isISend),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ImageRes.notice.toImage
                ..width = 24.w
                ..height = 24.h,
              StrRes.groupAc.toText..style = Styles.ts_0089FF_17sp,
            ],
          ),
          6.verticalSpace,
          content.toText..style = Styles.ts_0C1C33_17sp,
        ],
      ),
    );
  }
}

class TopNoticeView extends StatelessWidget {
  const TopNoticeView({
    Key? key,
    required this.content,
    this.onPreview,
    this.onClose,
  }) : super(key: key);
  final String content;
  final Function()? onPreview;
  final Function()? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Styles.primaryContainer,
        border: Border.all(
          color: Styles.primary.withValues(alpha: .14),
          width: Styles.dividerWidth,
        ),
        borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onPreview,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImageRes.notice.toImage
                  ..width = 24.w
                  ..height = 24.h,
                2.horizontalSpace,
                StrRes.groupAc.toText..style = Styles.ts_0089FF_17sp,
                const Spacer(),
                SizedBox(
                  width: Styles.controlHeight,
                  height: Styles.controlHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onClose,
                    child: Center(
                      child: ImageRes.closeGroupNotice.toImage
                        ..width = 16.w
                        ..height = 16.h,
                    ),
                  ),
                ),
              ],
            ),
            8.verticalSpace,
            content.toText
              ..style = Styles.ts_0C1C33_14sp
              ..maxLines = 2
              ..overflow = TextOverflow.ellipsis,
          ],
        ),
      ),
    );
  }
}
