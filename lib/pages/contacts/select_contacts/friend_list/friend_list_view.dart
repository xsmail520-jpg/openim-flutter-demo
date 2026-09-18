import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../select_contacts_logic.dart';
import 'friend_list_logic.dart';

class SelectContactsFromFriendsPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromFriendsLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.myFriend,
        showUnderline: true,
      ),
      backgroundColor: Styles.background,
      body: Column(
        children: [
          if (selectContactsLogic.isMultiModel)
            Obx(() => _buildSelectAllView()),
          Expanded(
            child: Obx(
              () => WrapAzListView<ISUserInfo>(
                data: logic.friendList,
                itemCount: logic.friendList.length,
                itemBuilder: (_, data, index) => _buildItemView(data),
              ),
            ),
          ),
          selectContactsLogic.checkedConfirmView,
        ],
      ),
    );
  }

  /// 全选作为独立命令行展示，与联系人正文分区但不形成悬浮卡片。
  Widget _buildSelectAllView() => Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        child: InkWell(
          onTap: logic.selectAll,
          child: Container(
            constraints: BoxConstraints(minHeight: 56.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                ChatRadio(checked: logic.isSelectAll),
                12.horizontalSpace,
                StrRes.selectAll.toText..style = Styles.ts_0C1C33_17sp_medium,
              ],
            ),
          ),
        ),
      );

  /// 联系人按连续名录行呈现，头像、名称和选择状态保持稳定的扫描层级。
  Widget _buildItemView(ISUserInfo info) {
    Widget buildChild() => Material(
          color: Styles.surface,
          child: InkWell(
            onTap: selectContactsLogic.onTap(info),
            child: Container(
              constraints: BoxConstraints(minHeight: 64.h),
              padding: EdgeInsets.only(left: 16.w, right: 28.w),
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
                  if (selectContactsLogic.isMultiModel) ...[
                    ChatRadio(
                      checked: selectContactsLogic.isChecked(info),
                      enabled: !selectContactsLogic.isDefaultChecked(info),
                    ),
                    12.horizontalSpace,
                  ],
                  AvatarView(
                    url: info.faceURL,
                    text: info.showName,
                    width: 42.w,
                    height: 42.h,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: info.showName.toText
                      ..style = Styles.ts_0C1C33_17sp
                      ..maxLines = 1
                      ..overflow = TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
    return selectContactsLogic.isMultiModel ? Obx(buildChild) : buildChild();
  }
}
