import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class RichTextInputBox extends StatefulWidget {
  const RichTextInputBox({
    Key? key,
    required this.voiceRecordBar,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.onTapCamera,
    this.showAlbumIcon = true,
    this.showCameraIcon = true,
    this.showCardIcon = true,
    this.showFileIcon = true,
    this.showLocationIcon = true,
    this.onTapAlbum,
    this.onTapCard,
    this.onTapFile,
    this.onTapLocation,
    this.onSend,
  }) : super(key: key);
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget voiceRecordBar;
  final bool enabled;
  final bool showAlbumIcon;
  final bool showCameraIcon;
  final bool showFileIcon;
  final bool showCardIcon;
  final bool showLocationIcon;
  final Function()? onTapAlbum;
  final Function()? onTapCamera;
  final Function()? onTapFile;
  final Function()? onTapCard;
  final Function()? onTapLocation;
  final Function()? onSend;

  @override
  State<RichTextInputBox> createState() => _RichTextInputBoxState();
}

class _RichTextInputBoxState extends State<RichTextInputBox> {
  bool _leftKeyboardButton = false;

  @override
  void initState() {
    widget.focusNode?.addListener(() {
      if (widget.focusNode!.hasFocus) {
        setState(() {
          _leftKeyboardButton = false;
        });
      }
    });
    super.initState();
  }

  double get _opacity => (widget.enabled ? 1 : .4);

  focus() => FocusScope.of(context).requestFocus(widget.focusNode);

  unfocus() => FocusScope.of(context).requestFocus(FocusNode());

  void onTapSpeak() {
    if (!widget.enabled) return;
    Permissions.microphone(() => setState(() {
          _leftKeyboardButton = true;
          unfocus();
        }));
  }

  void onTapLeftKeyboard() {
    if (!widget.enabled) return;
    setState(() {
      _leftKeyboardButton = false;
      focus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.c_F0F2F6,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 22.w,
            children: [
              if (widget.showAlbumIcon)
                _buildToolButton(
                  icon: ImageRes.toolboxAlbum1.toImage
                    ..width = 26.w
                    ..height = 22.h,
                  onTap: widget.onTapAlbum,
                ),
              if (widget.showCameraIcon)
                _buildToolButton(
                  icon: ImageRes.toolboxCamera1.toImage
                    ..width = 26.w
                    ..height = 22.h,
                  onTap: widget.onTapCamera,
                ),
              if (widget.showFileIcon)
                _buildToolButton(
                  icon: ImageRes.toolboxFile1.toImage
                    ..width = 26.w
                    ..height = 22.h,
                  onTap: widget.onTapFile,
                ),
              if (widget.showCardIcon)
                _buildToolButton(
                  icon: ImageRes.toolboxCard1.toImage
                    ..width = 26.w
                    ..height = 22.h,
                  onTap: widget.onTapCard,
                ),
              if (widget.showLocationIcon)
                _buildToolButton(
                  icon: ImageRes.toolboxLocation1.toImage
                    ..width = 16.w
                    ..height = 22.h,
                  onTap: widget.onTapLocation,
                ),
            ],
          ),
          if (widget.showAlbumIcon ||
              widget.showCameraIcon ||
              widget.showCardIcon ||
              widget.showFileIcon ||
              widget.showLocationIcon)
            15.verticalSpace,
          Row(
            children: [
              _buildToolButton(
                icon: (_leftKeyboardButton
                    ? ImageRes.openKeyboard.toImage
                    : ImageRes.openVoice.toImage)
                  ..width = 32.w
                  ..height = 32.h,
                onTap: _leftKeyboardButton ? onTapLeftKeyboard : onTapSpeak,
              ),
              12.horizontalSpace,
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
              10.horizontalSpace,
              if (!_leftKeyboardButton)
                SizedBox(
                  width: 78.w,
                  child: Button(
                    text: StrRes.send,
                    height: Styles.controlHeight,
                    enabled: widget.enabled,
                    onTap: widget.onSend,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required Widget icon,
    VoidCallback? onTap,
  }) =>
      Semantics(
        button: true,
        enabled: widget.enabled && onTap != null,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.enabled ? onTap : null,
          child: SizedBox(
            width: Styles.controlHeight,
            height: Styles.controlHeight,
            child: Center(
              child: Opacity(opacity: _opacity, child: icon),
            ),
          ),
        ),
      );

  Widget get _textFiled => Container(
        decoration: BoxDecoration(
          color: Styles.c_FFFFFF,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: ChatTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: Styles.ts_0C1C33_17sp,
          atStyle: Styles.ts_0089FF_17sp,
          enabled: true,
          textAlign: TextAlign.start,
        ),
      );
}
