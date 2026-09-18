import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class BottomSheetView extends StatelessWidget {
  const BottomSheetView({
    Key? key,
    required this.items,
    this.itemHeight,
    this.textStyle,
    this.mainAxisAlignment,
    this.isOverlaySheet = false,
    this.onCancel,
  }) : super(key: key);
  final List<SheetItem> items;
  final double? itemHeight;
  final TextStyle? textStyle;
  final MainAxisAlignment? mainAxisAlignment;
  final bool isOverlaySheet;
  final Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Styles.surface,
                borderRadius: BorderRadius.circular(Styles.radiusMedium.r),
                border: Border.all(
                  color: Styles.divider,
                  width: Styles.dividerWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    items.map((item) => _parseItem(context, item)).toList(),
              ),
            ),
            10.verticalSpace,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Styles.radiusMedium.r),
                border: Border.all(
                  color: Styles.divider,
                  width: Styles.dividerWidth,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _itemBgView(
                label: StrRes.cancel,
                textStyle: Styles.ts_0C1C33_17sp_semibold,
                onTap: isOverlaySheet
                    ? onCancel
                    : () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(Styles.radiusMedium.r),
                alignment: MainAxisAlignment.center,
              ),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _parseItem(BuildContext context, SheetItem item) {
    BorderRadius? borderRadius;
    int length = items.length;
    bool isLast = items.indexOf(item) == items.length - 1;
    bool isFirst = items.indexOf(item) == 0;
    if (length == 1) {
      borderRadius =
          item.borderRadius ?? BorderRadius.circular(Styles.radiusMedium.r);
    } else {
      borderRadius = item.borderRadius ??
          BorderRadius.only(
            topLeft:
                isFirst ? Radius.circular(Styles.radiusMedium.r) : Radius.zero,
            topRight:
                isFirst ? Radius.circular(Styles.radiusMedium.r) : Radius.zero,
            bottomLeft:
                isLast ? Radius.circular(Styles.radiusMedium.r) : Radius.zero,
            bottomRight:
                isLast ? Radius.circular(Styles.radiusMedium.r) : Radius.zero,
          );
    }
    return _itemBgView(
        label: item.label,
        textStyle: item.textStyle,
        icon: item.icon,
        alignment: item.alignment,
        line: !isLast,
        borderRadius: borderRadius,
        onTap: () {
          if (!isOverlaySheet) {
            // Pop the sheet's own route. Get.back() can pop the underlying
            // chat route when this sheet is opened above a regular Navigator
            // route such as the media preview.
            Navigator.of(context).pop(item.result);
          }
          item.onTap?.call();
        });
  }

  Widget _itemBgView({
    required String label,
    String? icon,
    Function()? onTap,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    MainAxisAlignment? alignment,
    bool line = false,
  }) =>
      Ink(
        decoration: BoxDecoration(
          color: Styles.c_FFFFFF,
          borderRadius: borderRadius,
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: line
                ? BoxDecoration(
                    border: BorderDirectional(
                      bottom: const BorderSide(
                        color: Styles.divider,
                        width: Styles.dividerWidth,
                      ),
                    ),
                  )
                : null,
            height: itemHeight ?? 52.h,
            child: Row(
              mainAxisAlignment:
                  alignment ?? mainAxisAlignment ?? MainAxisAlignment.center,
              children: [
                if (null != icon) 10.horizontalSpace,
                if (null != icon) _image(icon),
                if (null != icon) 5.horizontalSpace,
                _text(label, textStyle),
              ],
            ),
          ),
        ),
      );

  _text(String label, TextStyle? style) =>
      label.toText..style = (style ?? textStyle ?? Styles.ts_0C1C33_17sp);

  _image(String icon) => icon.toImage
    ..width = 24.w
    ..height = 24.h;
}

class SheetItem {
  final String label;
  final TextStyle? textStyle;
  final String? icon;
  final Function()? onTap;
  final BorderRadius? borderRadius;
  final MainAxisAlignment? alignment;
  final dynamic result;

  SheetItem({
    required this.label,
    this.textStyle,
    this.icon,
    this.onTap,
    this.borderRadius,
    this.alignment,
    this.result,
  });
}
