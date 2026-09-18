import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    Key? key,
    required this.index,
    required this.labels,
    this.selectedStyle,
    this.unselectedStyle,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorWidth,
    this.onTabChanged,
    this.height,
    this.showUnderline = false,
  }) : super(key: key);
  final int index;
  final List<String> labels;
  final TextStyle? selectedStyle;
  final TextStyle? unselectedStyle;
  final double? height;
  final Color? indicatorColor;
  final double? indicatorHeight;
  final double? indicatorWidth;
  final Function(int index)? onTabChanged;
  final bool showUnderline;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        border: showUnderline
            ? BorderDirectional(
                bottom: const BorderSide(
                  color: Styles.divider,
                  width: Styles.dividerWidth,
                ),
              )
            : null,
      ),
      child: Row(
        children: List.generate(labels.length, (i) => _buildItemView(i)),
      ),
    );
  }

  Widget _buildItemView(int i) => Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (null != onTabChanged) onTabChanged!(i);
            },
            child: SizedBox(
              height: height ?? Styles.controlHeight.h,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: labels.elementAt(i).toText
                      ..style = (i == index
                          ? selectedStyle ?? Styles.ts_0089FF_17sp_semibold
                          : unselectedStyle ?? Styles.ts_8E9AB0_17sp),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Visibility(
                      visible: i == index,
                      child: Container(
                        decoration: BoxDecoration(
                          color: indicatorColor ?? Styles.primary,
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                        height: indicatorHeight ?? 2.h,
                        width: indicatorWidth ?? 24.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class TabInfo {
  String label;
  TextStyle styleSel;
  TextStyle styleUnsel;
  double iconHeight;
  double iconWidth;
  String iconSel;
  String iconUnsel;

  TabInfo({
    required this.label,
    required this.styleSel,
    required this.styleUnsel,
    required this.iconSel,
    required this.iconUnsel,
    required this.iconHeight,
    required this.iconWidth,
  });
}
