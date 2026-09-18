import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'friend_requests_logic.dart';

class FriendRequestsPage extends StatelessWidget {
  final logic = Get.find<FriendRequestsLogic>();

  FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.newFriend, showUnderline: true),
      backgroundColor: Styles.background,
      body: Obx(() => ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            itemCount: logic.applicationList.length,
            itemBuilder: (_, index) =>
                _buildItemView(logic.applicationList[index]),
          )),
    );
  }

  Widget _buildItemView(FriendApplicationInfo info) {
    final isISendRequest = info.fromUserID == OpenIM.iMManager.userID;
    String? name = isISendRequest ? info.toNickname : info.fromNickname;
    String? faceURL = isISendRequest ? info.toFaceURL : info.fromFaceURL;
    String? reason = info.reqMsg;

    return Ink(
      color: Styles.surface,
      child: Container(
        constraints: BoxConstraints(minHeight: 80.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
              url: faceURL,
              text: name,
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (name ?? '').toText
                    ..style = Styles.ts_0C1C33_17sp_medium
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                  if (IMUtils.isNotNullEmptyStr(reason)) ...[
                    5.verticalSpace,
                    (reason ?? '').toText
                      ..style = Styles.ts_8E9AB0_14sp
                      ..maxLines = 2
                      ..overflow = TextOverflow.ellipsis,
                  ],
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

  /// 申请操作和结果占用同一尾部区域，避免姓名与状态在不同数据下跳位。
  Widget _buildActionOrStatus(
    FriendApplicationInfo info,
    bool isISendRequest,
  ) {
    if (info.isWaitingHandle && !isISendRequest) {
      return Button(
        text: StrRes.lookOver,
        textStyle: Styles.ts_FFFFFF_14sp_medium,
        onTap: () => logic.acceptFriendApplication(info),
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
      );
    }

    String? text;
    Color? color;
    if (info.isWaitingHandle) {
      text = StrRes.waitingForVerification;
      color = Styles.warning;
    } else if (info.isRejected) {
      text = StrRes.rejected;
      color = Styles.danger;
    } else if (info.isAgreed) {
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
