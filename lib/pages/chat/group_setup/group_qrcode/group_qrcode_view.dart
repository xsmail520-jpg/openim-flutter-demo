import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'group_qrcode_logic.dart';

class GroupQrcodePage extends StatelessWidget {
  final logic = Get.find<GroupQrcodeLogic>();

  GroupQrcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: TitleBar.back(title: StrRes.groupQrcode),
        backgroundColor: Styles.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Center(child: _buildQrcodeDocument()),
        ),
      ),
    );
  }

  /// 以带边框的文档面板集中呈现群身份、说明与二维码。
  Widget _buildQrcodeDocument() => Container(
        constraints: BoxConstraints(maxWidth: 343.w),
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: Styles.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 20.h),
              child: Row(
                children: [
                  AvatarView(
                    width: 48.w,
                    height: 48.h,
                    url: logic.groupSetupLogic.groupInfo.value.faceURL,
                    text: logic.groupSetupLogic.groupInfo.value.groupName,
                    textStyle: Styles.ts_FFFFFF_14sp,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child:
                        (logic.groupSetupLogic.groupInfo.value.groupName ?? '')
                            .toText
                          ..style = Styles.ts_0C1C33_20sp_medium
                          ..maxLines = 2
                          ..overflow = TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Styles.divider),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 26.h),
              child: Column(
                children: [
                  StrRes.groupQrcodeHint.toText
                    ..style = Styles.ts_8E9AB0_15sp
                    ..textAlign = TextAlign.center,
                  18.verticalSpace,
                  Container(
                    width: 208.w,
                    height: 208.w,
                    padding: EdgeInsets.all(13.w),
                    decoration: BoxDecoration(
                      color: Styles.surface,
                      border: Border.all(color: Styles.primary, width: 2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Styles.divider),
                      ),
                      child: QrImageView(
                        data: logic.buildQRContent(),
                        backgroundColor: Styles.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
