import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'process_group_requests_logic.dart';

class ProcessGroupRequestsPage extends StatelessWidget {
  final logic = Get.find<ProcessGroupRequestsLogic>();

  ProcessGroupRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.newGroup, showUnderline: true),
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
                    12.verticalSpace,
                    _buildSourceSection(),
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

  /// 入群申请概要按申请人、目标群两级信息展示，长内容保持可收缩。
  Widget _buildApplicantSection() => Container(
        constraints: BoxConstraints(minHeight: 84.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
              url: logic.applicationInfo.userFaceURL,
              text: logic.applicationInfo.nickname,
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (logic.applicationInfo.nickname ?? '').toText
                    ..style = Styles.ts_0C1C33_17sp_medium
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                  5.verticalSpace,
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: StrRes.applyJoin,
                      style: Styles.ts_8E9AB0_14sp,
                      children: [
                        WidgetSpan(child: 2.horizontalSpace),
                        TextSpan(
                          text: logic.groupName,
                          style: Styles.ts_0089FF_14sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildSourceSection() => Container(
        constraints: BoxConstraints(minHeight: 48.h),
        width: double.infinity,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: sprintf(StrRes.sourceFrom, [logic.sourceFrom]).toText
          ..style = Styles.ts_8E9AB0_14sp,
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
                onTap: logic.approve,
                text: StrRes.accept,
                textStyle: Styles.ts_FFFFFF_17sp,
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
            onTap: logic.reject,
            borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            child: Container(
              alignment: Alignment.center,
              child: StrRes.reject.toText..style = Styles.ts_FF381F_17sp,
            ),
          ),
        ),
      );
}
