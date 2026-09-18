import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sprintf/sprintf.dart';

import '../../../widgets/register_page_bg.dart';
import 'verify_phone_logic.dart';

class VerifyPhonePage extends StatelessWidget {
  final logic = Get.find<VerifyPhoneLogic>();

  VerifyPhonePage({super.key});

  @override
  Widget build(BuildContext context) => RegisterBgView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RegisterPageTitle(
              sprintf(
                StrRes.enterVerificationCode,
                [
                  logic.email?.isNotEmpty == true
                      ? StrRes.email
                      : StrRes.phoneNumber,
                ],
              ),
            ),
            12.verticalSpace,
            Text(
              '${logic.account} ${sprintf(StrRes.defaultVerificationCode, [
                    '666666'
                  ])}',
              style: Styles.ts_8E9AB0_12sp.copyWith(height: 1.5),
            ),
            28.verticalSpace,
            PinCodeTextField(
              appContext: context,
              controller: logic.codeEditCtrl,
              autoFocus: true,
              textStyle: Styles.ts_0C1C33_20sp_semibold,
              length: 6,
              obscureText: false,
              blinkWhenObscuring: true,
              animationType: AnimationType.fade,
              validator: (v) {
                return null;
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                activeColor: Styles.c_0089FF,
                selectedColor: Styles.c_0089FF,
                inactiveColor: Styles.c_E8EAEF,
                disabledColor: Styles.c_E8EAEF,
                activeFillColor: Styles.surface,
                selectedFillColor: Styles.primaryContainer,
                inactiveFillColor: Styles.surface,
                borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                borderWidth: 1,
                fieldHeight: Styles.controlHeight.h,
                fieldWidth: Styles.controlHeight.w,
              ),
              enableActiveFill: true,
              cursorColor: Styles.primary,
              animationDuration: 300.milliseconds,
              errorAnimationController: logic.codeErrorCtrl,
              keyboardType: TextInputType.number,
              onCompleted: (v) {
                logic.completed(v);
              },
              onSubmitted: (v) {
                logic.completed(v);
              },
              onChanged: (v) {},
              beforeTextPaste: (text) {
                return true;
              },
            ),
            VerifyCodeSendButton(
              sec: 300,
              onTapCallback: () => logic.requestVerificationCode(),
            ),
            48.verticalSpace,
            Obx(() => Button(
                  text: StrRes.nextStep,
                  enabled: logic.enabled.value,
                  onTap: () => logic.completed(logic.codeEditCtrl.text),
                )),
          ],
        ),
      );
}
