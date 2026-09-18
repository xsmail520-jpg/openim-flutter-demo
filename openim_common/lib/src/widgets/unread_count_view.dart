import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class UnreadCountView extends StatelessWidget {
  const UnreadCountView({
    Key? key,
    this.count = 0,
    this.size = 16,
    this.margin,
  }) : super(key: key);
  final int count;
  final double size;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: count > 0,
      child: Container(
        alignment: Alignment.center,
        margin: margin,
        padding: count > 99 ? EdgeInsets.symmetric(horizontal: 4.w) : null,
        constraints: BoxConstraints(minHeight: size, minWidth: size),
        decoration: _decoration,
        child: _text,
      ),
    );
  }

  Text get _text => Text(
        '${count > 99 ? '99+' : count}',
        style: TextStyle(
          fontSize: 10.sp,
          color: Styles.surface,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      );

  Decoration get _decoration => BoxDecoration(
        color: Styles.primary,
        shape: count > 99 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count > 99 ? BorderRadius.circular(8.r) : null,
      );
}
