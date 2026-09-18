import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

enum InputBoxType {
  phone,
  account,
  password,
  verificationCode,
  invitationCode,
}

class InputBox extends StatefulWidget {
  const InputBox.phone({
    super.key,
    required this.label,
    required this.code,
    this.onAreaCode,
    this.controller,
    this.focusNode,
    this.labelStyle,
    this.textStyle,
    this.codeStyle,
    this.hintStyle,
    this.formatHintStyle,
    this.hintText,
    this.formatHintText,
    this.margin,
    this.inputFormatters,
    this.keyBoardType,
  })  : obscureText = false,
        type = InputBoxType.phone,
        arrowColor = null,
        clearBtnColor = null,
        onSendVerificationCode = null;

  InputBox.account({
    super.key,
    required this.label,
    required this.code,
    this.onAreaCode,
    this.controller,
    this.focusNode,
    this.labelStyle,
    this.textStyle,
    this.codeStyle,
    this.hintStyle,
    this.formatHintStyle,
    this.hintText,
    this.formatHintText,
    this.margin,
    this.inputFormatters,
    this.keyBoardType,
  })  : obscureText = false,
        type = InputBoxType.account,
        arrowColor = null,
        clearBtnColor = null,
        onSendVerificationCode = null;

  const InputBox.password({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.labelStyle,
    this.textStyle,
    this.hintStyle,
    this.formatHintStyle,
    this.hintText,
    this.formatHintText,
    this.margin,
    this.inputFormatters,
    this.keyBoardType,
  })  : obscureText = true,
        type = InputBoxType.password,
        codeStyle = null,
        code = '',
        arrowColor = null,
        clearBtnColor = null,
        onSendVerificationCode = null,
        onAreaCode = null;

  const InputBox.verificationCode({
    super.key,
    required this.label,
    this.onSendVerificationCode,
    this.controller,
    this.focusNode,
    this.labelStyle,
    this.textStyle,
    this.hintStyle,
    this.formatHintStyle,
    this.hintText,
    this.formatHintText,
    this.margin,
    this.inputFormatters,
    this.keyBoardType,
  })  : obscureText = false,
        type = InputBoxType.verificationCode,
        code = '',
        codeStyle = null,
        onAreaCode = null,
        arrowColor = null,
        clearBtnColor = null;

  const InputBox.invitationCode({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.labelStyle,
    this.textStyle,
    this.formatHintStyle,
    this.hintStyle,
    this.hintText,
    this.formatHintText,
    this.margin,
    this.inputFormatters,
    this.keyBoardType,
  })  : obscureText = false,
        type = InputBoxType.invitationCode,
        code = '',
        codeStyle = null,
        onAreaCode = null,
        onSendVerificationCode = null,
        arrowColor = null,
        clearBtnColor = null;

  const InputBox({
    Key? key,
    required this.label,
    this.controller,
    this.focusNode,
    this.labelStyle,
    this.textStyle,
    this.hintStyle,
    this.codeStyle,
    this.formatHintStyle,
    this.code = '+86',
    this.hintText,
    this.formatHintText,
    this.arrowColor,
    this.clearBtnColor,
    this.obscureText = false,
    this.type = InputBoxType.account,
    this.onAreaCode,
    this.onSendVerificationCode,
    this.margin,
    this.inputFormatters,
    this.keyBoardType,
  }) : super(key: key);
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? codeStyle;
  final TextStyle? formatHintStyle;
  final String code;
  final String label;
  final String? hintText;
  final String? formatHintText;
  final Color? arrowColor;
  final Color? clearBtnColor;
  final bool obscureText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputBoxType type;
  final Function()? onAreaCode;
  final Future<bool> Function()? onSendVerificationCode;
  final EdgeInsetsGeometry? margin;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyBoardType;

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  late bool _obscureText;
  bool _showClearBtn = false;
  TextEditingController? _listenedController;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _attachController(widget.controller);
  }

  void _attachController(TextEditingController? controller) {
    _listenedController?.removeListener(_onChanged);
    _listenedController = controller;
    _listenedController?.addListener(_onChanged);
    _showClearBtn = controller?.text.isNotEmpty ?? false;
  }

  @override
  void didUpdateWidget(covariant InputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _attachController(widget.controller);
    }
  }

  void _onChanged() {
    if (!mounted) return;
    final controller = _listenedController;
    if (controller == null) return;

    final showClearBtn = controller.text.isNotEmpty;
    if (_showClearBtn == showClearBtn) return;

    setState(() {
      _showClearBtn = showClearBtn;
    });
  }

  @override
  void dispose() {
    _listenedController?.removeListener(_onChanged);
    super.dispose();
  }

  void _toggleEye() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: widget.labelStyle ?? Styles.ts_8E9AB0_12sp,
          ),
          8.verticalSpace,
          Container(
            height: Styles.controlHeight,
            padding: EdgeInsets.only(left: 12.w),
            decoration: BoxDecoration(
              color: Styles.surface,
              border: Border.all(color: Styles.divider, width: 1),
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.type == InputBoxType.phone ||
                    widget.onAreaCode != null)
                  _areaCodeView,
                _textField,
                _clearBtn,
                _eyeBtn,
                if (widget.type == InputBoxType.verificationCode)
                  VerifyCodedButton(
                    onTapCallback: widget.onSendVerificationCode,
                  ),
              ],
            ),
          ),
          if (null != widget.formatHintText)
            Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: widget.formatHintText!.toText
                ..style = (widget.formatHintStyle ?? Styles.ts_8E9AB0_12sp),
            ),
        ],
      ),
    );
  }

  Widget get _textField => Expanded(
        child: TextField(
          controller: widget.controller,
          keyboardType: _textInputType,
          textInputAction: TextInputAction.next,
          // Text fields should keep normal weight even when the surrounding
          // Material text theme uses medium/bold headings.
          style: (widget.textStyle ?? Styles.ts_0C1C33_17sp).copyWith(
            fontWeight: FontWeight.w400,
          ),
          autofocus: false,
          obscureText: _obscureText,
          focusNode: widget.focusNode,
          inputFormatters: [
            if (widget.type == InputBoxType.phone ||
                widget.type == InputBoxType.verificationCode)
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            if (null != widget.inputFormatters) ...widget.inputFormatters!,
          ],
          decoration: InputDecoration(
            hintText: widget.hintText,
            // 输入提示比已输入内容低一级，避免在高密度设备上显得过粗过大。
            hintStyle: (widget.hintStyle ?? Styles.ts_8E9AB0_16sp).copyWith(
              fontWeight: FontWeight.w400,
            ),
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      );

  Widget get _areaCodeView => SizedBox(
        height: Styles.controlHeight,
        child: GestureDetector(
          onTap: widget.onAreaCode,
          behavior: HitTestBehavior.translucent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.code,
                style: widget.codeStyle ?? Styles.ts_0C1C33_17sp,
              ),
              8.horizontalSpace,
              ImageRes.downArrow.toImage
                ..width = 8.49.w
                ..height = 8.49.h,
              Container(
                width: 1.w,
                height: 26.h,
                margin: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: Styles.c_E8EAEF,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        ),
      );

  Widget get _clearBtn => Visibility(
        visible: _showClearBtn,
        child: SizedBox(
          width: Styles.controlHeight,
          height: Styles.controlHeight,
          child: GestureDetector(
            onTap: () {
              widget.controller?.clear();
            },
            behavior: HitTestBehavior.translucent,
            child: Center(
              child: ImageRes.clearText.toImage
                ..width = 20.w
                ..height = 20.h,
            ),
          ),
        ),
      );

  Widget get _eyeBtn => Visibility(
        visible: widget.type == InputBoxType.password,
        child: SizedBox(
          width: Styles.controlHeight,
          height: Styles.controlHeight,
          child: GestureDetector(
            onTap: _toggleEye,
            behavior: HitTestBehavior.translucent,
            child: Center(
              child: (_obscureText
                  ? ImageRes.eyeClose.toImage
                  : ImageRes.eyeOpen.toImage)
                ..width = 20.w
                ..height = 20.h,
            ),
          ),
        ),
      );

  TextInputType? get _textInputType {
    if (widget.keyBoardType != null) {
      return widget.keyBoardType;
    }
    TextInputType? keyboardType;
    switch (widget.type) {
      case InputBoxType.phone:
        keyboardType = TextInputType.phone;
        break;
      case InputBoxType.account:
        keyboardType = TextInputType.text;
        break;
      case InputBoxType.password:
        keyboardType = TextInputType.text;
        break;
      case InputBoxType.verificationCode:
        keyboardType = TextInputType.number;
        break;
      case InputBoxType.invitationCode:
        keyboardType = TextInputType.text;
        break;
    }
    return keyboardType;
  }
}

class VerifyCodedButton extends StatefulWidget {
  final int seconds;

  final Future<bool> Function()? onTapCallback;

  const VerifyCodedButton({
    Key? key,
    this.seconds = 60,
    required this.onTapCallback,
  }) : super(key: key);

  @override
  State<VerifyCodedButton> createState() => _VerifyCodedButtonState();
}

class _VerifyCodedButtonState extends State<VerifyCodedButton> {
  Timer? _timer;
  late int _seconds;
  bool _firstTime = true;

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _seconds = widget.seconds;
  }

  void _start() {
    _firstTime = false;
    _timer = Timer.periodic(1.seconds, (timer) {
      if (!mounted) return;
      if (_seconds == 0) {
        _cancel();
        setState(() {});
        return;
      }
      _seconds--;
      setState(() {});
    });
  }

  void _cancel() {
    if (null != _timer) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _reset() {
    if (_seconds != widget.seconds) {
      _seconds = widget.seconds;
    }
    _cancel();
    setState(() {});
  }

  void _restart() {
    _reset();
    _start();
  }

  bool get _isEnabled => _seconds == 0 || _firstTime;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_isEnabled) {
            widget.onTapCallback?.call().then((start) {
              if (start) _restart();
            });
          }
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: Styles.controlHeight),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: (_isEnabled ? StrRes.sendVerificationCode : '${_seconds}S')
              .toText
            ..style =
                (_isEnabled ? Styles.ts_0089FF_17sp : Styles.ts_8E9AB0_17sp),
        ),
      );
}
