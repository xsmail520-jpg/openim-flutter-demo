import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import 'my_info_logic.dart';

class MyInfoPage extends StatelessWidget {
  final logic = Get.find<MyInfoLogic>();
  final imLogic = Get.find<IMController>();

  MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.myInfo),
      backgroundColor: Styles.background,
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Column(
            children: [
              _buildSection(
                showAccent: true,
                children: [
                  _buildItemView(
                    label: StrRes.avatar,
                    isAvatar: true,
                    value: imLogic.userInfo.value.nickname,
                    url: imLogic.userInfo.value.faceURL,
                    onTap: logic.openPhotoSheet,
                  ),
                  _buildItemView(
                    label: StrRes.name,
                    value: imLogic.userInfo.value.nickname,
                    onTap: logic.editMyName,
                  ),
                  _buildItemView(
                    label: StrRes.personalIntro,
                    value: IMUtils.emptyStrToNull(imLogic.userInfo.value.ex) ??
                        StrRes.noPersonalIntro,
                    onTap: logic.editPersonalIntro,
                  ),
                  _buildItemView(
                    label: StrRes.gender,
                    value: imLogic.userInfo.value.isMale
                        ? StrRes.man
                        : StrRes.woman,
                    onTap: logic.selectGender,
                  ),
                  _buildItemView(
                    label: StrRes.birthDay,
                    value: DateUtil.formatDateMs(
                      imLogic.userInfo.value.birth ?? 0,
                      format: IMUtils.getTimeFormat1(),
                    ),
                    onTap: logic.openDatePicker,
                    showDivider: false,
                  ),
                ],
              ),
              12.verticalSpace,
              _buildSection(
                children: [
                  _buildItemView(
                    label: StrRes.mobile,
                    value: imLogic.userInfo.value.phoneNumber,
                    showRightArrow: false,
                  ),
                  _buildItemView(
                    label: StrRes.email,
                    value: imLogic.userInfo.value.email,
                    onTap: logic.editEmail,
                  ),
                  _buildItemView(
                    label: StrRes.imchatID,
                    value: imLogic.userInfo.value.userID,
                    showRightArrow: false,
                    onTap: logic.copyID,
                  ),
                  _buildItemView(
                    label: StrRes.changeLoginPassword,
                    onTap: logic.changePassword,
                    showDivider: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 资料字段按身份信息与联系方式分组，使用细边框和连续分隔行。
  Widget _buildSection({
    required List<Widget> children,
    bool showAccent = false,
  }) =>
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Styles.divider),
        ),
        child: Column(
          children: [
            if (showAccent) Container(height: 3.h, color: Styles.primary),
            ...children,
          ],
        ),
      );

  Widget _buildItemView({
    required String label,
    String? value,
    String? url,
    bool isAvatar = false,
    bool showRightArrow = true,
    bool showDivider = true,
    Function()? onTap,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: isAvatar ? 76.h : 58.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: Styles.divider))
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 82.w,
                  child: label.toText..style = Styles.ts_0C1C33_17sp,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: isAvatar
                        ? AvatarView(
                            width: 48.w,
                            height: 48.h,
                            url: url,
                            text: value,
                            textStyle: Styles.ts_FFFFFF_10sp,
                          )
                        : ((IMUtils.emptyStrToNull(value) ?? '').toText
                          ..style = Styles.ts_8E9AB0_17sp
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis
                          ..textAlign = TextAlign.right),
                  ),
                ),
                if (showRightArrow) ...[
                  6.horizontalSpace,
                  ImageRes.rightArrow.toImage
                    ..width = 24.w
                    ..height = 24.h,
                ],
              ],
            ),
          ),
        ),
      );
}
