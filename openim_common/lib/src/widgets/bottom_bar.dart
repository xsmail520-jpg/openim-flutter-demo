import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
    this.index = 0,
    required this.items,
  }) : super(key: key);
  final int index;
  final List<BottomBarItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: Styles.surface,
        border: const BorderDirectional(
          top: BorderSide(
            color: Styles.divider,
            width: Styles.dividerWidth,
          ),
        ),
      ),
      child: Row(
        children: List.generate(
            items.length,
            (index) => _buildItemView(
                  i: index,
                  item: items.elementAt(index),
                )).toList(),
      ),
    );
  }

  Widget _buildItemView({required int i, required BottomBarItem item}) =>
      Expanded(
        child: Material(
          color: Styles.surface,
          child: InkWell(
            onDoubleTap: () => item.onDoubleClick?.call(i),
            onTap: () => item.onClick?.call(i),
            splashColor: Styles.primary.withValues(alpha: .05),
            highlightColor: Styles.primary.withValues(alpha: .03),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: Styles.controlHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      (i == index
                          ? item.selectedImgRes.toImage
                          : item.unselectedImgRes.toImage)
                        ..width = item.imgWidth
                        ..height = item.imgHeight,
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Transform.translate(
                          offset: const Offset(2, -2),
                          child: UnreadCountView(count: item.count ?? 0),
                        ),
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  item.label.toText
                    ..style = i == index
                        ? (item.selectedStyle ??
                            Styles.ts_0089FF_12sp
                                .copyWith(fontWeight: FontWeight.w600))
                        : (item.unselectedStyle ?? Styles.ts_8E9AB0_12sp),
                ],
              ),
            ),
          ),
        ),
        /*child: InkWell(
          onTap: () {
            if (item.onClick != null) item.onClick!(i);
          },
          onDoubleTap: () => item.onDoubleClick?.call(i),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  (i == index
                      ? item.selectedImgRes.toImage
                      : item.unselectedImgRes.toImage)
                    ..width = item.imgWidth
                    ..height = item.imgHeight,
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: const Offset(2, -2),
                      child: UnreadCountView(count: item.count ?? 0),
                    ),
                  ),
                ],
              ),
              4.verticalSpace,
              item.label.toText
                ..style = i == index
                    ? (item.selectedStyle ?? Styles.ts_0089FF_10sp_semibold)
                    : (item.unselectedStyle ?? Styles.ts_8E9AB0_10sp_semibold),
            ],
          ),
        ),*/
      );
}

class BottomBarItem {
  final String selectedImgRes;
  final String unselectedImgRes;
  final String label;
  final TextStyle? selectedStyle;
  final TextStyle? unselectedStyle;
  final double imgWidth;
  final double imgHeight;
  final Function(int index)? onClick;
  final Function(int index)? onDoubleClick;
  final Stream<int>? steam;
  final int? count;

  BottomBarItem(
      {required this.selectedImgRes,
      required this.unselectedImgRes,
      required this.label,
      this.selectedStyle,
      this.unselectedStyle,
      required this.imgWidth,
      required this.imgHeight,
      this.onClick,
      this.onDoubleClick,
      this.steam,
      this.count});
}
