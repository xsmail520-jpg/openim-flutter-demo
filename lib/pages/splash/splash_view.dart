import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'splash_logic.dart';

class SplashPage extends StatelessWidget {
  final logic = Get.find<SplashLogic>();

  SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 104.w,
                    height: 128.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Styles.surface,
                      border: Border.all(color: Styles.divider),
                      borderRadius:
                          BorderRadius.circular(Styles.radiusMedium.r),
                    ),
                    child: ImageRes.splashLogo.toImage
                      ..width = 64.w
                      ..height = 64.w,
                  ),
                ),
              ),
              Obx(() => Column(
                    children: [
                      if (logic.networkStatusText.isNotEmpty) ...[
                        Text(
                          logic.networkStatusText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Styles.muted,
                            fontSize: 13.sp,
                          ),
                        ),
                        12.verticalSpace,
                      ],
                      if (logic.isCheckingNetwork)
                        SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (logic.canRetryNetwork)
                        OutlinedButton(
                          onPressed: logic.retryNetwork,
                          child: Text(StrRes.retryConnection),
                        )
                      else
                        Container(
                          width: 72.w,
                          height: 3.h,
                          color: Styles.primary,
                        ),
                    ],
                  )),
              8.verticalSpace,
              Container(
                width: 24.w,
                height: 1.h,
                color: Styles.divider,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
