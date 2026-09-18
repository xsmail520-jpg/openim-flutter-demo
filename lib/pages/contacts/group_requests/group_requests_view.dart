import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'group_requests_logic.dart';

class GroupRequestsPage extends StatelessWidget {
  final logic = Get.find<GroupRequestsLogic>();

  GroupRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.newGroupRequest,
        showUnderline: true,
      ),
      backgroundColor: Styles.background,
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            itemCount: logic.list.length,
            itemBuilder: (_, index) => _buildItemView(logic.list[index]),
          )),
    );
  }

  Widget _buildItemView(GroupApplicationInfo info) {
    final isISendRequest = info.userID == OpenIM.iMManager.userID;
    return Ink(
      color: Styles.surface,
      child: Container(
        constraints: BoxConstraints(minHeight: 92.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: const BoxDecoration(
          border: BorderDirectional(
            bottom: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Row(
          children: [
            AvatarView(
              width: 44.w,
              height: 44.h,
              url: info.userFaceURL,
              text: info.nickname,
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (info.nickname ?? '').toText
                    ..style = Styles.ts_0C1C33_17sp_medium
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                  5.verticalSpace,
                  if (!logic.isInvite(info))
                    RichText(
                      text: TextSpan(
                        text: StrRes.applyJoin,
                        style: Styles.ts_8E9AB0_14sp,
                        children: [
                          WidgetSpan(child: 2.horizontalSpace),
                          TextSpan(
                            text: logic.getGroupName(info),
                            style: Styles.ts_0089FF_14sp,
                          ),
                        ],
                      ),
                    )
                  else
                    RichText(
                      text: TextSpan(
                        text: logic.getInviterNickname(info),
                        style: Styles.ts_0089FF_14sp,
                        children: [
                          WidgetSpan(child: 2.horizontalSpace),
                          TextSpan(
                            text: StrRes.invite,
                            style: Styles.ts_8E9AB0_14sp,
                          ),
                          WidgetSpan(child: 2.horizontalSpace),
                          TextSpan(
                            text: info.nickname,
                            style: Styles.ts_0089FF_14sp,
                          ),
                          WidgetSpan(child: 2.horizontalSpace),
                          TextSpan(
                            text: StrRes.joinIn,
                            style: Styles.ts_8E9AB0_14sp,
                          ),
                          WidgetSpan(child: 2.horizontalSpace),
                          TextSpan(
                            text: logic.getGroupName(info),
                            style: Styles.ts_0089FF_14sp,
                          ),
                        ],
                      ),
                    ),
                  if (null != IMUtils.emptyStrToNull(info.reqMsg))
                    Padding(
                      padding: EdgeInsets.only(top: 5.h),
                      child: sprintf(StrRes.applyReason, [info.reqMsg!]).toText
                        ..style = Styles.ts_8E9AB0_14sp
                        ..maxLines = 2
                        ..overflow = TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            12.horizontalSpace,
            _buildActionOrStatus(info, isISendRequest),
          ],
        ),
      ),
    );
  }

  /// 操作按钮与处理状态共享尾部槽位，保持申请列表的行内对齐。
  Widget _buildActionOrStatus(
    GroupApplicationInfo info,
    bool isISendRequest,
  ) {
    if (info.handleResult == 0 && !isISendRequest) {
      return Button(
        text: StrRes.lookOver,
        textStyle: Styles.ts_FFFFFF_14sp_medium,
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        onTap: () => logic.handle(info),
      );
    }

    String? text;
    Color? color;
    if (info.handleResult == 0) {
      text = StrRes.waitingForVerification;
      color = Styles.warning;
    } else if (info.handleResult == -1) {
      text = StrRes.rejected;
      color = Styles.danger;
    } else if (info.handleResult == 1) {
      text = StrRes.approved;
      color = Styles.success;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isISendRequest) ...[
          ImageRes.sendRequests.toImage
            ..width = 20.w
            ..height = 20.h
            ..color = Styles.primary,
          if (text != null) 6.horizontalSpace,
        ],
        if (text != null && color != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .08),
              border: Border.all(
                color: color.withValues(alpha: .32),
                width: Styles.dividerWidth,
              ),
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            ),
            child: text.toText
              ..style = Styles.ts_8E9AB0_12sp.copyWith(color: color),
          ),
      ],
    );
  }
}
