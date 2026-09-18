import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'friend_list_logic.dart';

class FriendListPage extends StatelessWidget {
  final logic = Get.find<FriendListLogic>();

  FriendListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: StrRes.myFriend, showUnderline: true),
      backgroundColor: Styles.background,
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: Obx(
          () => WrapAzListView<ISUserInfo>(
            data: logic.friendList,
            itemCount: logic.friendList.length,
            itemBuilder: (_, data, index) => _buildItemView(data),
          ),
        ),
      ),
    );
  }

  /// 好友行使用头像、姓名和进入提示的固定三段结构，保证字母索引下快速扫读。
  Widget _buildItemView(ISUserInfo info) => Ink(
        color: Styles.surface,
        child: InkWell(
          onTap: () => logic.viewFriendInfo(info),
          child: Container(
            constraints: BoxConstraints(minHeight: 68.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                  url: info.faceURL,
                  text: info.showName,
                ),
                12.horizontalSpace,
                Expanded(
                  child: info.showName.toText
                    ..style = Styles.ts_0C1C33_17sp_medium
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                ),
                8.horizontalSpace,
                ImageRes.rightArrow.toImage
                  ..width = 20.w
                  ..height = 20.h,
              ],
            ),
          ),
        ),
      );
}
