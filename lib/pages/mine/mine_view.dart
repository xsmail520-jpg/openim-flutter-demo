import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'mine_logic.dart';

class MinePage extends StatelessWidget {
  final logic = Get.find<MineLogic>();

  MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Styles.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Styles.background,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Obx(_buildIdentityHeader),
                _buildSectionGap(),
                _buildSettingsGroup([
                  _buildItemView(
                    icon: ImageRes.myInfo,
                    label: StrRes.myInfo,
                    onTap: logic.viewMyInfo,
                  ),
                  _buildDivider(),
                  _buildItemView(
                    icon: ImageRes.accountSetup,
                    label: StrRes.privacySecurity,
                    onTap: logic.privacySecurity,
                  ),
                  _buildDivider(),
                  _buildItemView(
                    icon: ImageRes.accountSetup,
                    label: StrRes.dataStorage,
                    onTap: logic.storageUsage,
                  ),
                  _buildDivider(),
                  _buildItemView(
                    icon: ImageRes.accountSetup,
                    label: StrRes.notificationSettings,
                    onTap: logic.notificationSettings,
                  ),
                  _buildDivider(),
                  _buildItemView(
                    icon: ImageRes.accountSetup,
                    label: '钱包与认证',
                    onTap: logic.businessCenter,
                  ),
                  _buildDivider(),
                  _buildItemView(
                    icon: ImageRes.accountSetup,
                    label: StrRes.accountSetup,
                    onTap: logic.accountSetup,
                  ),
                  _buildDivider(),
                  _buildItemView(
                    icon: ImageRes.accountSetup,
                    label: '登录设备与安全',
                    onTap: logic.security,
                  ),
                ]),
                _buildSectionGap(),
                _buildSettingsGroup([
                  _buildItemView(
                    icon: ImageRes.aboutUs,
                    label: StrRes.aboutUs,
                    onTap: logic.aboutUs,
                  ),
                ]),
                _buildSectionGap(),
                _buildSettingsGroup([
                  _buildItemView(
                    icon: ImageRes.logout,
                    label: StrRes.logout,
                    onTap: logic.logout,
                    isDanger: true,
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityHeader() => Material(
        color: Styles.primary,
        child: InkWell(
          onTap: logic.viewMyInfo,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 156.h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StrRes.mine,
                    style: Styles.ts_FFFFFF_20sp_medium,
                  ),
                  20.verticalSpace,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Styles.surface,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: AvatarView(
                          url: logic.imLogic.userInfo.value.faceURL,
                          text: logic.imLogic.userInfo.value.nickname,
                          width: 58.w,
                          height: 58.h,
                          borderRadius: BorderRadius.circular(8.r),
                          textStyle: Styles.ts_FFFFFF_14sp,
                        ),
                      ),
                      14.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              logic.imLogic.userInfo.value.nickname ?? '',
                              style: Styles.ts_FFFFFF_20sp_medium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            4.verticalSpace,
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: logic.copyID,
                                borderRadius: BorderRadius.circular(
                                  Styles.radiusSmall.r,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${StrRes.userID}：${logic.imLogic.userInfo.value.userID ?? ''}',
                                          style: Styles.ts_FFFFFF_12sp.copyWith(
                                            color: Styles.surface
                                                .withValues(alpha: .76),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      6.horizontalSpace,
                                      ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          Styles.surface.withValues(alpha: .76),
                                          BlendMode.srcIn,
                                        ),
                                        child: ImageRes.mineCopy.toImage
                                          ..width = 15.w
                                          ..height = 15.h,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: StrRes.myQrcode,
                        onPressed: logic.viewMyQrcode,
                        icon: Icon(
                          Icons.qr_code_2_rounded,
                          color: Styles.surface.withValues(alpha: .82),
                          size: 26.w,
                        ),
                      ),
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Styles.surface.withValues(alpha: .76),
                          BlendMode.srcIn,
                        ),
                        child: ImageRes.rightArrow.toImage
                          ..width = 20.w
                          ..height = 20.h,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildSectionGap() => Container(
        height: 8.h,
        color: Styles.background,
      );

  Widget _buildSettingsGroup(List<Widget> children) => Container(
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border(
            top: BorderSide(color: Styles.divider, width: Styles.dividerWidth),
            bottom:
                BorderSide(color: Styles.divider, width: Styles.dividerWidth),
          ),
        ),
        child: Column(children: children),
      );

  Widget _buildDivider() => Padding(
        padding: EdgeInsets.only(left: 52.w),
        child: const Divider(height: Styles.dividerWidth),
      );

  Widget _buildItemView({
    required String icon,
    required String label,
    bool isDanger = false,
    Function()? onTap,
  }) =>
      Material(
        color: Styles.surface,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 56.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      isDanger ? Styles.danger : Styles.ink,
                      BlendMode.srcIn,
                    ),
                    child: icon.toImage
                      ..width = 22.w
                      ..height = 22.h,
                  ),
                  14.horizontalSpace,
                  label.toText
                    ..style = isDanger
                        ? Styles.ts_FF381F_17sp
                        : Styles.ts_0C1C33_17sp,
                  const Spacer(),
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Styles.muted,
                      BlendMode.srcIn,
                    ),
                    child: ImageRes.rightArrow.toImage
                      ..width = 20.w
                      ..height = 20.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
