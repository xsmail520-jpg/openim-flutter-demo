import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'select_contacts_logic.dart';

class SelectContactsPage extends StatelessWidget {
  final logic = Get.find<SelectContactsLogic>();

  SelectContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(showUnderline: true),
      backgroundColor: Styles.background,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: 8.verticalSpace),
                  SliverToBoxAdapter(child: _buildCategorySection()),
                  if (logic.conversationList.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Container(
                        height: 38.h,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: StrRes.recentConversations.toText
                          ..style = Styles.ts_8E9AB0_12sp,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: logic.conversationList.length,
                        (_, index) => _buildRecentConversationsItemView(
                          logic.conversationList.elementAt(index),
                          isFirst: index == 0,
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: 12.verticalSpace),
                ],
              ),
            ),
          ),
          logic.checkedConfirmView,
        ],
      ),
    );
  }

  /// 选择来源集中在同一连续分区，图标帮助区分快速入口但不新增业务内容。
  Widget _buildCategorySection() {
    final showGroup = !logic.hiddenGroup;
    return Container(
      decoration: const BoxDecoration(
        color: Styles.surface,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Styles.divider,
            width: Styles.dividerWidth,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildCategoryItemView(
            assetsName: ImageRes.myFriend,
            label: StrRes.myFriend,
            showDivider: showGroup,
            onTap: logic.selectFromMyFriend,
          ),
          if (showGroup)
            _buildCategoryItemView(
              assetsName: ImageRes.myGroup,
              label: StrRes.myGroup,
              onTap: logic.selectFromMyGroup,
            ),
        ],
      ),
    );
  }

  /// 来源行提供完整 64dp 点击区域，并通过缩进分隔维持名录秩序。
  Widget _buildCategoryItemView({
    required String assetsName,
    required String label,
    bool showDivider = false,
    Function()? onTap,
  }) =>
      Material(
        color: Styles.surface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: 64.h),
            margin: EdgeInsets.only(left: 16.w),
            padding: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              border: showDivider
                  ? const BorderDirectional(
                      bottom: BorderSide(
                        color: Styles.divider,
                        width: Styles.dividerWidth,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                assetsName.toImage
                  ..width = 40.w
                  ..height = 40.h,
                12.horizontalSpace,
                label.toText..style = Styles.ts_0C1C33_17sp_medium,
                const Spacer(),
                ImageRes.rightArrow.toImage
                  ..width = 20.w
                  ..height = 20.h,
              ],
            ),
          ),
        ),
      );

  /// 最近会话复用原有数据，只调整为边界清晰的连续选择名录。
  Widget _buildRecentConversationsItemView(
    ConversationInfo info, {
    required bool isFirst,
  }) {
    Widget buildChild() => Material(
          color: Styles.surface,
          child: InkWell(
            onTap: logic.onTap(info),
            child: Container(
              constraints: BoxConstraints(minHeight: 68.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  top: isFirst
                      ? const BorderSide(
                          color: Styles.divider,
                          width: Styles.dividerWidth,
                        )
                      : BorderSide.none,
                  bottom: const BorderSide(
                    color: Styles.divider,
                    width: Styles.dividerWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (logic.isMultiModel) ...[
                    ChatRadio(checked: logic.isChecked(info)),
                    12.horizontalSpace,
                  ],
                  AvatarView(
                    url: info.faceURL,
                    text: info.showName,
                    isGroup: !info.isSingleChat,
                    width: 42.w,
                    height: 42.h,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: (info.showName ?? '').toText
                      ..style = Styles.ts_0C1C33_17sp
                      ..maxLines = 1
                      ..overflow = TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
    return logic.isMultiModel ? Obx(buildChild) : buildChild();
  }
}

class CheckedConfirmView extends StatelessWidget {
  CheckedConfirmView({Key? key}) : super(key: key);
  final logic = Get.find<SelectContactsLogic>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(minHeight: 72.h),
        decoration: const BoxDecoration(
          color: Styles.surface,
          border: BorderDirectional(
            top: BorderSide(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: logic.viewSelectedContactsList,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            sprintf(StrRes.selectedPeopleCount,
                                [logic.checkedList.length]).toText
                              ..style = Styles.ts_0089FF_14sp_medium,
                            ImageRes.expandUpArrow.toImage
                              ..width = 20.w
                              ..height = 20.h,
                          ],
                        ),
                        if (logic.checkedList.isNotEmpty) 4.verticalSpace,
                        logic.checkedStrTips.toText
                          ..style = Styles.ts_8E9AB0_14sp
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis,
                      ],
                    ),
                  ),
                ),
                Button(
                  height: 44.h,
                  enabled: logic.enabledConfirmButton,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  text: sprintf(StrRes.confirmSelectedPeople, [
                    logic.checkedList.length,
                    '999',
                  ]),
                  textStyle: Styles.ts_FFFFFF_14sp,
                  onTap: logic.confirmSelectedList,
                ),
              ],
            )),
      ),
    );
  }
}

class SelectedContactsListView extends StatelessWidget {
  SelectedContactsListView({Key? key}) : super(key: key);
  final logic = Get.find<SelectContactsLogic>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: 548.h),
        decoration: BoxDecoration(
          color: Styles.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Styles.radiusMedium.r),
            topRight: Radius.circular(Styles.radiusMedium.r),
          ),
        ),
        child: Obx(() => Column(
              children: [
                Container(
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
                      sprintf(StrRes.selectedPeopleCount,
                          [logic.checkedList.length]).toText
                        ..style = Styles.ts_0C1C33_17sp_medium,
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => Get.back(),
                        child: Container(
                          height: 52.h,
                          width: 44.w,
                          alignment: Alignment.center,
                          child: StrRes.confirm.toText
                            ..style = Styles.ts_0089FF_17sp_semibold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: logic.checkedList.length,
                    shrinkWrap: true,
                    itemBuilder: (_, index) => _buildItemView(index),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildItemView(int index) {
    final info = logic.checkedList.values.elementAt(index);
    String? name;
    String? faceURL;
    bool isGroup = false;
    name = SelectContactsLogic.parseName(info);
    faceURL = SelectContactsLogic.parseFaceURL(info);
    if (info is ConversationInfo) {
      isGroup = !info.isSingleChat;
    } else if (info is GroupInfo) {
      isGroup = true;
      name = info.groupName;
      faceURL = info.faceURL;
    } else if (info is UserInfo) {
      name = info.nickname;
      faceURL = info.faceURL;
    }
    return Container(
      constraints: BoxConstraints(minHeight: 68.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color: Styles.surface,
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
            url: faceURL,
            text: name,
            isGroup: isGroup,
            width: 42.w,
            height: 42.h,
          ),
          12.horizontalSpace,
          Expanded(
            child: (name ?? '').toText
              ..style = Styles.ts_0C1C33_17sp
              ..maxLines = 1
              ..overflow = TextOverflow.ellipsis,
          ),
          Material(
            color: Colors.transparent,
            child: Ink(
              height: 44.h,
              decoration: BoxDecoration(
                color: Styles.primaryContainer,
                borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                border: Border.all(
                  color: Styles.primary,
                  width: Styles.dividerWidth,
                ),
              ),
              child: InkWell(
                onTap: () => logic.removeItem(info),
                borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Center(
                    child: StrRes.remove.toText
                      ..style = Styles.ts_0089FF_14sp_medium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
