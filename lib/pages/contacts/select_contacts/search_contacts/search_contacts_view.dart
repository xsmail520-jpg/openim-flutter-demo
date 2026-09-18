import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:search_keyword_text/search_keyword_text.dart';

import '../select_contacts_logic.dart';
import 'search_contacts_logic.dart';

class SelectContactsFromSearchPage extends StatelessWidget {
  final logic = Get.find<SelectContactsFromSearchLogic>();
  final selectContactsLogic = Get.find<SelectContactsLogic>();

  SelectContactsFromSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: TitleBar.search(
          focusNode: logic.focusNode,
          controller: logic.searchCtrl,
          onSubmitted: (_) => logic.search(),
          onCleared: () => logic.focusNode.requestFocus(),
        ),
        backgroundColor: Styles.background,
        body: SafeArea(
          top: false,
          child: Obx(
            () => logic.isSearchNotResult
                ? _emptyListView
                : ListView.builder(
                    padding: EdgeInsets.only(top: 8.h),
                    itemCount: logic.resultList.length,
                    itemBuilder: (_, index) => _buildItemView(
                      logic.resultList.elementAt(index),
                      isFirst: index == 0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 搜索结果沿用联系人名录层级，并以连续细分隔线承载任意结果长度。
  Widget _buildItemView(dynamic info, {required bool isFirst}) {
    Widget buildChild() => Material(
          color: Styles.surface,
          child: InkWell(
            onTap: selectContactsLogic.onTap(info),
            child: Container(
              constraints: BoxConstraints(minHeight: 68.h),
              padding: EdgeInsets.only(left: 16.w, right: 28.w),
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
                  if (selectContactsLogic.isMultiModel) ...[
                    ChatRadio(
                      checked: selectContactsLogic.isChecked(info),
                      enabled: !selectContactsLogic.isDefaultChecked(info),
                    ),
                    12.horizontalSpace,
                  ],
                  AvatarView(
                    url: logic.parseFaceURL(info),
                    text: logic.parseNickname(info),
                    isGroup: info is GroupInfo,
                    width: 42.w,
                    height: 42.h,
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: SearchKeywordText(
                      text: logic.parseNickname(info) ?? '',
                      keyText: logic.searchCtrl.text.trim(),
                      style: Styles.ts_0C1C33_17sp,
                      keyStyle: Styles.ts_0089FF_17sp_medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    return selectContactsLogic.isMultiModel ? Obx(buildChild) : buildChild();
  }

  /// 空结果占据可用区域居中反馈，避免提示漂浮在搜索栏下方。
  Widget get _emptyListView => SizedBox.expand(
        child: Center(
          child: StrRes.searchNotFound.toText..style = Styles.ts_8E9AB0_16sp,
        ),
      );
}
