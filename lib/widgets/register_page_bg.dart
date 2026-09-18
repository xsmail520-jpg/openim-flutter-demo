import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class RegisterBgView extends StatelessWidget {
  const RegisterBgView({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return Material(
      color: Styles.background,
      child: TouchCloseSoftKeyboard(
        child: SafeArea(
          child: Column(
            children: [
              Container(height: 4.h, color: Styles.primary),
              Container(
                height: 52.h,
                decoration: const BoxDecoration(
                  color: Styles.surface,
                  border: BorderDirectional(
                    bottom: BorderSide(
                      color: Styles.divider,
                      width: Styles.dividerWidth,
                    ),
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                    child: SizedBox(
                      width: Styles.controlHeight.w,
                      height: Styles.controlHeight.h,
                      child: Center(
                        child: ImageRes.backBlack.toImage
                          ..width = 24.w
                          ..height = 24.h,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    24.h,
                    20.w,
                    24.h + keyboardInset,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 28.h),
                    decoration: BoxDecoration(
                      color: Styles.surface,
                      border: Border.all(
                        color: Styles.divider,
                        width: Styles.dividerWidth,
                      ),
                      borderRadius:
                          BorderRadius.circular(Styles.radiusMedium.r),
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 认证流程统一使用红色标识线与正文标题，避免每一步形成不同视觉层级。
class RegisterPageTitle extends StatelessWidget {
  const RegisterPageTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3.w,
            height: 25.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: Styles.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Styles.ink,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      );
}
