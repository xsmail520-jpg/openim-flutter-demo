import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import 'conversation_logic.dart';

class ConversationPage extends StatelessWidget {
  final logic = Get.find<ConversationLogic>();

  ConversationPage({super.key});

  static const _systemUiStyle = SystemUiOverlayStyle(
    statusBarColor: Styles.primary,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  /// 会话首页显式恢复浅色系统栏，避免从深色页面返回后继承错误状态。
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiStyle,
      child: Obx(() => Scaffold(
            backgroundColor: Styles.background,
            appBar: TitleBar.conversation(
                statusStr: logic.imSdkStatus,
                isFailed: logic.isFailedSdkStatus,
                popCtrl: logic.popCtrl,
                onAddFriend: logic.addFriend,
                onAddGroup: logic.addGroup,
                onCreateGroup: logic.createGroup,
                left: Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      StrRes.home.toText..style = Styles.ts_FFFFFF_20sp_medium,
                      8.horizontalSpace,
                      if (null != logic.imSdkStatus &&
                          (!logic.reInstall || logic.isFailedSdkStatus))
                        Flexible(
                            child: SyncStatusView(
                          isFailed: logic.isFailedSdkStatus,
                          statusStr: logic.imSdkStatus!,
                        )),
                    ],
                  ),
                )),
            body: Column(
              children: [
                _buildSearchEntry(),
                const Divider(height: Styles.dividerWidth),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, index) => _buildItemView(
                      logic.list.elementAt(index),
                    ),
                    separatorBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(left: 72.w),
                      child: const Divider(height: Styles.dividerWidth),
                    ),
                    itemCount: logic.list.length,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  /// 搜索入口复用既有全局搜索路由，不在会话页新增筛选或数据状态。
  Widget _buildSearchEntry() => Material(
        color: Styles.primary,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
          child: Semantics(
            button: true,
            label: StrRes.search,
            child: InkWell(
              onTap: logic.globalSearch,
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
              child: IgnorePointer(
                child: SearchBox(
                  enabled: false,
                  height: Styles.controlHeight,
                  hintText: StrRes.search,
                  backgroundColor: Styles.surface,
                ),
              ),
            ),
          ),
        ),
      );

  /// 会话保持单列紧凑扫描，置顶或未读态仅以淡红底区分，不改变业务排序。
  Widget _buildItemView(ConversationInfo info) {
    final unreadCount = logic.getUnreadCount(info);
    final isEmphasized = info.isPinned == true;
    return Material(
      color: isEmphasized ? Styles.primaryContainer : Styles.surface,
      child: InkWell(
        onTap: () => logic.toChat(conversationInfo: info),
        onLongPress: () => logic.showConversationActions(info),
        child: SizedBox(
          height: 68.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                AvatarView(
                  width: 44.w,
                  height: 44.h,
                  text: logic.getShowName(info),
                  url: info.faceURL,
                  isGroup: logic.isGroupChat(info),
                  textStyle: Styles.ts_FFFFFF_14sp_medium,
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: logic.getShowName(info).toText
                              ..style = Styles.ts_0C1C33_17sp.copyWith(
                                fontWeight: FontWeight.w600,
                              )
                              ..maxLines = 1
                              ..overflow = TextOverflow.ellipsis,
                          ),
                          12.horizontalSpace,
                          logic.getTime(info).toText
                            ..style = Styles.ts_8E9AB0_12sp,
                        ],
                      ),
                      4.verticalSpace,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: MatchTextView(
                              text: logic.getContent(info),
                              textStyle: Styles.ts_8E9AB0_14sp,
                              prefixSpan: TextSpan(
                                text: '',
                                children: [
                                  if (logic.getUnreadCount(info) > 0)
                                    TextSpan(
                                      text: '[${sprintf(StrRes.nPieces, [
                                            logic.getUnreadCount(info)
                                          ])}] ',
                                      style: Styles.ts_8E9AB0_14sp,
                                    ),
                                  TextSpan(
                                    text: logic.getPrefixTag(info),
                                    style: Styles.ts_0089FF_14sp,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          8.horizontalSpace,
                          UnreadCountView(count: unreadCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
