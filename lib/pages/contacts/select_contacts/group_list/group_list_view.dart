import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../select_contacts_logic.dart';
import 'group_list_logic.dart';

class SelectContactsFromGroupPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromGroupLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.myGroup,
        showUnderline: true,
      ),
      backgroundColor: Styles.background,
      body: Column(
        children: [
          if (selectContactsLogic.isMultiModel)
            Obx(() => _buildSelectAllView()),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: logic.allList.length,
                itemBuilder: (_, index) => _buildItemView(logic.allList[index]),
              ),
            ),
          ),
          selectContactsLogic.checkedConfirmView,
        ],
      ),
    );
  }

  /// 全选命令与群组名录分层，保留一眼可见的批量操作入口。
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

  /// 群组名称与人数形成主次两级，连续分隔线便于快速扫描长列表。
  Widget _buildItemView(GroupInfo info) {
    Widget buildChild() => Material(
          color: Styles.surface,
          child: InkWell(
            onTap: selectContactsLogic.onTap(info),
            child: Container(
              constraints: BoxConstraints(minHeight: 68.h),
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
                    text: info.groupName,
                    isGroup: true,
                    width: 42.w,
                    height: 42.h,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (info.groupName ?? '').toText
                          ..style = Styles.ts_0C1C33_17sp
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis,
                        3.verticalSpace,
                        sprintf(StrRes.nPerson, [info.memberCount]).toText
                          ..style = Styles.ts_8E9AB0_14sp,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    return selectContactsLogic.isMultiModel ? Obx(buildChild) : buildChild();
  }
}
