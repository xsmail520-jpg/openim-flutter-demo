import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class SyncStatusView extends StatelessWidget {
  const SyncStatusView({
    Key? key,
    required this.isFailed,
    required this.statusStr,
  }) : super(key: key);
  final bool isFailed;
  final String statusStr;

  @override
  Widget build(BuildContext context) {
    Logger.print('Sync Status View: $isFailed, $statusStr');
    return Container(
      constraints: BoxConstraints(minHeight: 28.h),
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isFailed ? Styles.dangerContainer : Styles.background,
        border: Border.all(
          color:
              isFailed ? Styles.danger.withValues(alpha: .2) : Styles.divider,
          width: Styles.dividerWidth,
        ),
        borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isFailed
              ? (ImageRes.syncFailed.toImage
                ..width = 12.w
                ..height = 12.h)
              : SizedBox(
                  width: 12.w,
                  height: 12.h,
                  child: CupertinoActivityIndicator(
                    color: Styles.c_0089FF,
                    radius: 6.r,
                  ),
                ),
          4.horizontalSpace,
          statusStr.toText
            ..style =
                (isFailed ? Styles.ts_FF381F_12sp : Styles.ts_0089FF_12sp),
        ],
      ),
    );
  }
}
