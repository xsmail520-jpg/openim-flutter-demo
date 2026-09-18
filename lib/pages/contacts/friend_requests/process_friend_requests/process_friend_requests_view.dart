import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'process_friend_requests_logic.dart';

class ProcessFriendRequestsPage extends StatelessWidget {
  final logic = Get.find<ProcessFriendRequestsLogic>();

  ProcessFriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.newFriend, showUnderline: true),
      backgroundColor: Styles.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  children: [
                    _buildApplicantSection(),
                    if (IMUtils.isNotNullEmptyStr(
                      logic.applicationInfo.reqMsg,
                    )) ...[
                      12.verticalSpace,
                      _buildReasonSection(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  /// 申请人资料作为独立连续分区，长昵称保持单行截断。
  Widget _buildApplicantSection() => Container(
        constraints: BoxConstraints(minHeight: 76.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            AvatarView(
              width: 48.w,
              height: 48.h,
              url: logic.applicationInfo.fromFaceURL,
              text: logic.applicationInfo.fromNickname,
            ),
            12.horizontalSpace,
            Expanded(
              child: (logic.applicationInfo.fromNickname ?? '').toText
                ..style = Styles.ts_0C1C33_17sp_medium
                ..maxLines = 1
                ..overflow = TextOverflow.ellipsis,
            ),
          ],
        ),
      );

  Widget _buildReasonSection() => Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Container(
          constraints: BoxConstraints(minHeight: 80.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Styles.background,
            border: Border(
              left: BorderSide(color: Styles.primary, width: 3.w),
              top: const BorderSide(
                color: Styles.divider,
                width: Styles.dividerWidth,
              ),
              right: const BorderSide(
                color: Styles.divider,
                width: Styles.dividerWidth,
              ),
              bottom: const BorderSide(
                color: Styles.divider,
                width: Styles.dividerWidth,
              ),
            ),
            borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          ),
          child: (logic.applicationInfo.reqMsg ?? '').toText
            ..style = Styles.ts_0C1C33_17sp,
        ),
      );

  Widget _buildActionBar() => Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: BorderDirectional(
            top: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(child: _buildRejectButton()),
            12.horizontalSpace,
            Expanded(
              child: Button(
                text: StrRes.accept,
                textStyle: Styles.ts_FFFFFF_17sp,
                onTap: logic.acceptFriendApplication,
              ),
            ),
          ],
        ),
      );

  Widget _buildRejectButton() => Material(
        color: Colors.transparent,
        child: Ink(
          height: 44.h,
          decoration: BoxDecoration(
            color: Styles.surface,
            border: Border.all(
              color: Styles.danger,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          ),
          child: InkWell(
            onTap: logic.refuseFriendApplication,
            borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            child: Container(
              alignment: Alignment.center,
              child: StrRes.reject.toText..style = Styles.ts_FF381F_17sp,
            ),
          ),
        ),
      );
}
