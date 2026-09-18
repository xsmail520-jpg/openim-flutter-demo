import 'package:flutter/material.dart';
import 'package:openim_common/openim_common.dart';

class TouchCloseSoftKeyboard extends StatelessWidget {
  final Widget child;
  final Function? onTouch;
  final bool isGradientBg;

  const TouchCloseSoftKeyboard({
    Key? key,
    required this.child,
    this.onTouch,
    this.isGradientBg = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        onTouch?.call();
      },
      child: isGradientBg
          ? Container(
              color: Styles.background,
              child: child,
            )
          : child,
    );
  }
}
