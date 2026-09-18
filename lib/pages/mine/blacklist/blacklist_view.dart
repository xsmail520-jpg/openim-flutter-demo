import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'blacklist_logic.dart';

class BlacklistPage extends StatelessWidget {
  final logic = Get.find<BlacklistLogic>();

  BlacklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.blacklist),
      backgroundColor: Styles.background,
      body: Obx(
        () => logic.blacklist.isEmpty
            ? _emptyListView
            : Container(
                margin: EdgeInsets.only(top: 12.h),
                decoration: BoxDecoration(
                  color: Styles.surface,
                  border: Border.symmetric(
                    horizontal: BorderSide(color: Styles.divider),
                  ),
                ),
                child: ListView.builder(
                  itemCount: logic.blacklist.length,
                  itemBuilder: (_, index) =>
                      _buildItemView(logic.blacklist[index]),
                ),
              ),
      ),
    );
  }

  /// 黑名单成员保持连续列表密度，移除操作改为明确的危险描边按钮。
  Widget _buildItemView(BlacklistInfo info) => Material(
        color: Styles.surface,
        child: InkWell(
          onTap: () => logic.remove(info),
          child: Container(
            constraints: BoxConstraints(minHeight: 68.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Styles.divider)),
            ),
            child: Row(
              children: [
                AvatarView(
                  width: 44.w,
                  height: 44.h,
                  text: info.nickname,
                  url: info.faceURL,
                ),
                12.horizontalSpace,
                Expanded(
                  child: (info.nickname ?? '').toText
                    ..style = Styles.ts_0C1C33_17sp
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                ),
                Container(
                  constraints: BoxConstraints(minWidth: 52.w, minHeight: 36.h),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: Styles.danger),
                  ),
                  child: StrRes.remove.toText..style = Styles.ts_FF381F_14sp,
                ),
              ],
            ),
          ),
        ),
      );

  /// 空状态收拢为低装饰的信息面板，保留原图与说明。
  Widget get _emptyListView => Center(
        child: Container(
          width: 220.w,
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          decoration: BoxDecoration(
            color: Styles.surface,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Styles.divider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 72.w, height: 3.h, color: Styles.primary),
              24.verticalSpace,
              ImageRes.blacklistEmpty.toImage
                ..width = 112.w
                ..height = 112.h,
              16.verticalSpace,
              StrRes.blacklistEmpty.toText
                ..style = Styles.ts_8E9AB0_16sp
                ..textAlign = TextAlign.center,
            ],
          ),
        ),
      );
}
