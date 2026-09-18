import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

double kInputBoxMinHeight = 56.h;

class ChatInputBox extends StatefulWidget {
  const ChatInputBox({
    Key? key,
    required this.toolbox,
    required this.voiceRecordBar,
    this.controller,
    this.focusNode,
    this.style,
    this.atStyle,
    this.enabled = true,
    this.isNotInGroup = false,
    this.hintText,
    this.forceCloseToolboxSub,
    this.quoteContent,
    this.onClearQuote,
    this.onSend,
    this.directionalText,
    this.onCloseDirectional,
  }) : super(key: key);
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final TextStyle? style;
  final TextStyle? atStyle;
  final bool enabled;
  final bool isNotInGroup;
  final String? hintText;
  final Widget toolbox;
  final Widget voiceRecordBar;
  final Stream? forceCloseToolboxSub;
  final String? quoteContent;
  final Function()? onClearQuote;
  final ValueChanged<String>? onSend;
  final TextSpan? directionalText;
  final VoidCallback? onCloseDirectional;

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState
    extends State<ChatInputBox> /*with TickerProviderStateMixin */ {
  bool _toolsVisible = false;
  bool _leftKeyboardButton = false;
  bool _sendButtonVisible = false;

  bool get _showQuoteView => IMUtils.isNotNullEmptyStr(widget.quoteContent);

  double get _opacity => (widget.enabled ? 1 : .4);

  bool get _showDirectionalView => widget.directionalText != null;

  @override
  void initState() {
    widget.focusNode?.addListener(() {
      if (widget.focusNode!.hasFocus) {
        setState(() {
          _toolsVisible = false;
          _leftKeyboardButton = false;
        });
      }
    });

    widget.forceCloseToolboxSub?.listen((value) {
      if (!mounted) return;
      setState(() {
        _toolsVisible = false;
      });
    });

    widget.controller?.addListener(() {
      setState(() {
        _sendButtonVisible = widget.controller!.text.isNotEmpty;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) widget.controller?.clear();
    return widget.isNotInGroup
        ? const ChatDisableInputBox()
        : Column(
            children: [
              Container(
                constraints: BoxConstraints(minHeight: kInputBoxMinHeight),
                decoration: const BoxDecoration(
                  color: Styles.surface,
                  border: Border(
                    top: BorderSide(
                      color: Styles.divider,
                      width: Styles.dividerWidth,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    10.horizontalSpace,
                    Expanded(
                      child: Stack(
                        children: [
                          Offstage(
                            offstage: _leftKeyboardButton,
                            child: _textFiled,
                          ),
                          Offstage(
                            offstage: !_leftKeyboardButton,
                            child: widget.voiceRecordBar,
                          ),
                        ],
                      ),
                    ),
                    8.horizontalSpace,
                    _buildTrailingAction(),
                    10.horizontalSpace,
                  ],
                ),
              ),
              if (_showDirectionalView)
                _SubView(
                  textSpan: widget.directionalText,
                  onClose: () {
                    widget.onCloseDirectional?.call();
                  },
                ),
              Visibility(
                visible: _toolsVisible,
                child: FadeInUp(
                  duration: const Duration(milliseconds: 200),
                  child: widget.toolbox,
                ),
              ),
            ],
          );
  }

  Widget get _textFiled => Container(
        margin: EdgeInsets.only(top: 8.h, bottom: _showQuoteView ? 4.h : 8.h),
        decoration: BoxDecoration(
          color: Styles.primarySoft,
          border: Border.all(
            color: Styles.divider,
            width: Styles.dividerWidth,
          ),
          borderRadius: BorderRadius.circular(9.r),
        ),
        child: ChatTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: widget.style ?? Styles.ts_0C1C33_17sp,
          atStyle: widget.atStyle ?? Styles.ts_0089FF_17sp,
          enabled: widget.enabled,
          hintText: widget.hintText,
          textAlign: widget.enabled ? TextAlign.start : TextAlign.center,
        ),
      );

  Widget _buildTrailingAction() => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _sendButtonVisible ? send : toggleToolbox,
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            width: (_sendButtonVisible ? 54 : Styles.controlHeight).w,
            height: 38.h,
            decoration: BoxDecoration(
              color: _sendButtonVisible ? Styles.primary : Styles.surface,
              border: Border.all(
                color: _sendButtonVisible ? Styles.primary : Styles.divider,
              ),
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            ),
            child: Center(
              child: _sendButtonVisible
                  ? Text(
                      StrRes.send,
                      style: Styles.ts_FFFFFF_14sp_medium,
                    )
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Styles.primary.withValues(alpha: _opacity),
                        BlendMode.srcIn,
                      ),
                      child: ImageRes.openToolbox.toImage
                        ..width = 24.w
                        ..height = 24.h,
                    ),
            ),
          ),
        ),
      );

  void send() {
    if (!widget.enabled) return;
    if (null != widget.onSend && null != widget.controller) {
      widget.onSend!(widget.controller!.text.toString().trim());
    }
  }

  void toggleToolbox() {
    if (!widget.enabled) return;
    setState(() {
      _toolsVisible = !_toolsVisible;
      _leftKeyboardButton = false;
      if (_toolsVisible) {
        unfocus();
      } else {
        focus();
      }
    });
  }

  void onTapLeftKeyboard() {
    if (!widget.enabled) return;
    setState(() {
      _leftKeyboardButton = false;
      _toolsVisible = false;
      focus();
    });
  }

  void onTapRightKeyboard() {
    if (!widget.enabled) return;
    setState(() {
      _toolsVisible = false;
      focus();
    });
  }

  focus() => FocusScope.of(context).requestFocus(widget.focusNode);

  unfocus() => FocusScope.of(context).requestFocus(FocusNode());
}

class _SubView extends StatelessWidget {
  const _SubView({
    this.onClose,
    this.title,
    this.content,
    this.textSpan,
  }) : assert(content != null || textSpan != null,
            'Either content or textSpan must be provided.');
  final VoidCallback? onClose;
  final String? title;
  final String? content;
  final InlineSpan? textSpan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8.h, left: 12.w, right: 12.w),
      color: Styles.surface,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onClose,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: Styles.controlHeight,
          ),
          padding: EdgeInsets.only(left: 10.w),
          decoration: BoxDecoration(
            color: Styles.surface,
            border: Border.all(
              color: Styles.divider,
              width: Styles.dividerWidth,
            ),
            borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: Styles.ts_8E9AB0_14sp,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (content != null)
                      Text(
                        content!,
                        style: Styles.ts_8E9AB0_14sp,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (textSpan != null)
                      Expanded(
                        child: RichText(
                          text: textSpan!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: Styles.controlHeight,
                height: Styles.controlHeight,
                child: Center(
                  child: ImageRes.delQuote.toImage
                    ..width = 14.w
                    ..height = 14.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
