import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  static const _commonEmojis = <String>[
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '🙂',
    '🙃',
    '😉',
    '😍',
    '🥰',
    '😘',
    '😋',
    '😎',
    '🤩',
    '🥳',
    '😏',
    '😒',
    '😔',
    '😢',
    '😭',
    '😤',
    '😡',
    '🤔',
    '🤭',
    '🤫',
    '😴',
    '🤢',
    '😱',
    '👍',
    '👎',
    '👌',
    '✌️',
    '🤝',
    '🙏',
    '👏',
    '💪',
    '❤️',
    '💔',
    '💯',
    '🔥',
    '🎉',
    '🎁',
    '🌹',
    '⭐',
  ];

  final logic = Get.find<ChatLogic>(tag: GetTags.chat);

  ChatPage({super.key});

  /// 为消息列保留稳定的侧边留白，避免气泡与屏幕边缘形成视觉拥挤。
  Widget _buildItemView(Message message) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: ChatItemView(
          key: logic.itemKey(message),
          message: message,
          textScaleFactor: logic.scaleFactor.value,
          allAtMap: logic.getAtMapping(message),
          timelineStr: logic.getShowTime(message),
          sendStatusSubject: logic.sendStatusSub,
          leftNickname: logic.getNewestNickname(message),
          leftFaceUrl: logic.getNewestFaceURL(message),
          rightNickname: logic.senderName,
          rightFaceUrl: OpenIM.iMManager.userInfo.faceURL,
          showLeftNickname: !logic.isSingleChat,
          showRightNickname: !logic.isSingleChat,
          onFailedToResend: () => logic.failedResend(message),
          onClickItemView: () => logic.parseClickEvent(message),
          onLongPressItemView: () => logic.showMessageActions(message),
          visibilityChange: (msg, visible) {
            logic.markMessageAsRead(message, visible);
          },
          onLongPressRightAvatar: () {},
          onTapLeftAvatar: () {
            logic.onTapLeftAvatar(message);
          },
          onVisibleTrulyText: (text) {
            logic.copyTextMap[message.clientMsgID] = text;
          },
          customTypeBuilder: _buildCustomTypeItemView,
          patterns: <MatchPattern>[
            MatchPattern(
              type: PatternType.email,
              onTap: logic.clickLinkText,
            ),
            MatchPattern(
              type: PatternType.url,
              onTap: logic.clickLinkText,
            ),
            MatchPattern(
              type: PatternType.mobile,
              onTap: logic.clickLinkText,
            ),
            MatchPattern(
              type: PatternType.tel,
              onTap: logic.clickLinkText,
            ),
          ],
          mediaItemBuilder: (context, message) {
            return _buildMediaItem(context, message);
          },
          onTapUserProfile: handleUserProfileTap,
        ),
      );

  void handleUserProfileTap(
      ({
        String userID,
        String name,
        String? faceURL,
        String? groupID
      }) userProfile) {
    final userInfo = UserInfo(
        userID: userProfile.userID,
        nickname: userProfile.name,
        faceURL: userProfile.faceURL);
    logic.viewUserInfo(userInfo);
  }

  Widget? _buildMediaItem(BuildContext context, Message message) {
    if (message.contentType != MessageType.picture &&
        message.contentType != MessageType.video) {
      return null;
    }

    return GestureDetector(
      onTap: () async {
        try {
          IMUtils.previewMediaFile(
              context: context,
              message: message,
              onAutoPlay: (index) {
                return !logic.playOnce;
              },
              muted: logic.rtcIsBusy,
              onPageChanged: (index) {
                logic.playOnce = true;
              }).then((value) {
            logic.playOnce = false;
          });
        } catch (e) {
          IMViews.showToast(e.toString());
        }
      },
      child: Hero(
        tag: message.clientMsgID!,
        child: _buildMediaContent(message),
        placeholderBuilder:
            (BuildContext context, Size heroSize, Widget child) => child,
      ),
    );
  }

  Widget _buildMediaContent(Message message) {
    final isOutgoing = message.sendID == OpenIM.iMManager.userID;

    if (message.isVideoType) {
      return const SizedBox();
    } else {
      return ChatPictureView(
        isISend: isOutgoing,
        message: message,
      );
    }
  }

  CustomTypeInfo? _buildCustomTypeItemView(_, Message message) {
    final data = IMUtils.parseCustomMessage(message);
    if (null != data) {
      final viewType = data['viewType'];
      if (viewType == CustomMessageType.call) {
        final type = data['type'];
        final content = data['content'];
        final view = ChatCallItemView(type: type, content: content);
        return CustomTypeInfo(view);
      } else if (viewType == CustomMessageType.deletedByFriend ||
          viewType == CustomMessageType.blockedByFriend) {
        final view = ChatFriendRelationshipAbnormalHintView(
          name: logic.nickname.value,
          onTap: logic.sendFriendVerification,
          blockedByFriend: viewType == CustomMessageType.blockedByFriend,
          deletedByFriend: viewType == CustomMessageType.deletedByFriend,
        );
        return CustomTypeInfo(view, false, false);
      } else if (viewType == CustomMessageType.removedFromGroup) {
        return CustomTypeInfo(
          StrRes.removedFromGroupHint.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.groupDisbanded) {
        return CustomTypeInfo(
          StrRes.groupDisbanded.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      }
    }
    return null;
  }

  Widget? get _groupCallHintView => null;

  Widget _buildPinnedAnnouncement() {
    if (!logic.isGroupChat) return const SizedBox.shrink();
    return Obx(() {
      if (logic.announcement.value.isEmpty) {
        return const SizedBox.shrink();
      }
      return InkWell(
        onTap: () => Get.dialog(
          Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('群公告', style: Styles.ts_0C1C33_17sp_medium),
                  12.verticalSpace,
                  Text(logic.announcement.value, style: Styles.ts_0C1C33_14sp),
                  16.verticalSpace,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => Get.back(), child: const Text('关闭')),
                  ),
                ],
              ),
            ),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          color: Styles.primaryContainer,
          child: Row(children: [
            Icon(Icons.campaign_outlined, size: 18.w, color: Styles.primary),
            8.horizontalSpace,
            Expanded(
              child: Text(
                logic.announcement.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Styles.ts_0C1C33_14sp,
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _buildMentionBanner() {
    if (!logic.isGroupChat) return const SizedBox.shrink();
    if (logic.conversationInfo.groupAtType == GroupAtType.atNormal) {
      return const SizedBox.shrink();
    }
    return InkWell(
      onTap: logic.jumpToMention,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        color: Styles.surface,
        child: Row(
          children: [
            Icon(Icons.alternate_email, size: 18.w, color: Styles.primary),
            8.horizontalSpace,
            Expanded(
                child: Text('有人在群里提及你，点击定位消息', style: Styles.ts_0089FF_14sp)),
            Icon(Icons.chevron_right, size: 18.w, color: Styles.primary),
          ],
        ),
      ),
    );
  }

  void _openVoiceRecorder() {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 28.h),
          decoration: BoxDecoration(
            color: Styles.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
          ),
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    logic.isVoiceRecording.value
                        ? '正在录音 ${logic.voiceRecordingSeconds.value} 秒'
                        : '点击开始录音',
                    style: Styles.ts_0C1C33_17sp_medium,
                  ),
                  18.verticalSpace,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: logic.isVoiceRecording.value
                          ? logic.finishVoiceRecording
                          : logic.startVoiceRecording,
                      icon: Icon(logic.isVoiceRecording.value
                          ? Icons.send_rounded
                          : Icons.mic_rounded),
                      label:
                          Text(logic.isVoiceRecording.value ? '结束并发送' : '开始录音'),
                    ),
                  ),
                  if (logic.isVoiceRecording.value) ...[
                    8.verticalSpace,
                    TextButton(
                      onPressed: () async {
                        await logic.cancelVoiceRecording();
                        Get.back();
                      },
                      child: const Text('取消录音'),
                    ),
                  ],
                ],
              )),
        ),
      ),
      isScrollControlled: true,
    ).whenComplete(logic.cancelVoiceRecording);
  }

  /// 将常用 Unicode 表情插入当前光标位置，沿用普通文本消息协议。
  void _insertEmoji(String emoji) {
    final value = logic.inputCtrl.value;
    final selection = value.selection;
    final start = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final text = value.text.replaceRange(start, end, emoji);
    logic.inputCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  /// 显示轻量常用表情面板，不引入额外 SDK 或自定义消息格式。
  void _openEmojiPicker() {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
          decoration: BoxDecoration(
            color: Styles.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      StrRes.toolboxEmoji,
                      style: Styles.ts_0C1C33_17sp_medium,
                    ),
                  ),
                  IconButton(
                    tooltip: StrRes.cancel,
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(
                height: 246.h,
                child: GridView.builder(
                  itemCount: _commonEmojis.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    childAspectRatio: 1.18,
                  ),
                  itemBuilder: (_, index) => InkWell(
                    onTap: () => _insertEmoji(_commonEmojis[index]),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: Text(
                        _commonEmojis[index],
                        style: TextStyle(fontSize: 25.sp),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// 消息与输入区共用白色底板，顶栏分隔由 TitleBar 统一负责。
  Widget _buildConversationBody() => ColoredBox(
        color: Styles.background,
        child: ClipRect(
          child: WaterMarkBgView(
            text: '',
            path: logic.background.value,
            backgroundColor: Styles.background,
            floatView: _groupCallHintView,
            bottomView: ChatInputBox(
              forceCloseToolboxSub: logic.forceCloseToolbox,
              controller: logic.inputCtrl,
              focusNode: logic.focusNode,
              enabled: !logic.isGroupLockedForMe,
              hintText: logic.isGroupLockedForMe ? '群已锁定，暂时不能发送消息' : null,
              isNotInGroup: logic.isInvalidGroup,
              directionalText: logic.directionalText(),
              onCloseDirectional: logic.onClearDirectional,
              onSend: (v) => logic.sendTextMsg(),
              toolbox: ChatToolBox(
                onTapAlbum: logic.onTapAlbum,
                onTapCamera: logic.onTapCamera,
                onTapEmoji: _openEmojiPicker,
                onTapCall: logic.isGroupChat ? null : logic.call,
                onTapVoice: _openVoiceRecorder,
                onTapFavorite: logic.openFavorites,
              ),
              voiceRecordBar: const SizedBox(),
            ),
            child: ChatListView(
              onTouch: () => logic.closeToolbox(),
              itemCount: logic.messageList.length,
              controller: logic.scrollController,
              onScrollToBottomLoad: logic.onScrollToBottomLoad,
              onScrollToTop: logic.onScrollToTop,
              itemBuilder: (_, index) {
                final message = logic.indexOfMessage(index);
                return Obx(() => _buildItemView(message));
              },
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Styles.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: logic.willPop(),
        child: Obx(() {
          return Scaffold(
            backgroundColor: Styles.background,
            appBar: TitleBar.chat(
              title: logic.nickname.value,
              member: logic.memberStr,
              onCloseMultiModel: logic.exit,
              onClickMoreBtn: logic.chatSetup,
              onClickCallBtn: logic.isGroupChat ? null : logic.call,
            ),
            body: SafeArea(
              top: false,
              child: Column(children: [
                _buildPinnedAnnouncement(),
                _buildMentionBanner(),
                Expanded(child: _buildConversationBody()),
              ]),
            ),
          );
        }),
      ),
    );
  }
}
