import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({
    Key? key,
    this.height,
    this.left,
    this.center,
    this.right,
    this.backgroundColor,
    this.showUnderline = false,
    this.centerOnScreen = false,
  }) : super(key: key);
  final double? height;
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final Color? backgroundColor;
  final bool showUnderline;
  final bool centerOnScreen;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final useLightForeground = backgroundColor == Styles.primary;
    final centeredEdgeWidth = null != right ? 72.w : Styles.controlHeight;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: useLightForeground
          ? const SystemUiOverlayStyle(
              statusBarColor: Styles.primary,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Styles.surface,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
      child: Container(
        color: backgroundColor ?? Styles.c_FFFFFF,
        padding: EdgeInsets.only(top: mq.padding.top),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: showUnderline
              ? BoxDecoration(
                  border: BorderDirectional(
                    bottom: const BorderSide(
                      color: Styles.divider,
                      width: Styles.dividerWidth,
                    ),
                  ),
                )
              : null,
          child: centerOnScreen
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    if (null != center)
                      Positioned.fill(
                        left: centeredEdgeWidth,
                        right: centeredEdgeWidth,
                        child: Center(child: center),
                      ),
                    if (null != left)
                      Align(alignment: Alignment.centerLeft, child: left),
                    if (null != right)
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: centeredEdgeWidth,
                          height: Styles.controlHeight,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: right,
                          ),
                        ),
                      ),
                  ],
                )
              : Row(
                  children: [
                    if (null != left) left!,
                    if (null != center) center!,
                    if (null != right) right!,
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? Styles.controlHeight);

  TitleBar.conversation(
      {super.key,
      String? statusStr,
      bool isFailed = false,
      Function()? onAddFriend,
      Function()? onAddGroup,
      Function()? onCreateGroup,
      CustomPopupMenuController? popCtrl,
      this.left})
      : backgroundColor = Styles.primary,
        height = 56,
        showUnderline = false,
        centerOnScreen = false,
        center = null,
        right = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopButton(
              popCtrl: popCtrl,
              menus: [
                PopMenuInfo(
                  text: StrRes.addFriend,
                  iconWidget: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Styles.primary,
                    size: 20.w,
                  ),
                  onTap: onAddFriend,
                ),
                PopMenuInfo(
                  text: StrRes.addGroup,
                  iconWidget: Icon(
                    Icons.group_add_rounded,
                    color: Styles.primary,
                    size: 20.w,
                  ),
                  onTap: onAddGroup,
                ),
                PopMenuInfo(
                  text: StrRes.createGroup,
                  iconWidget: Icon(
                    Icons.add_comment_rounded,
                    color: Styles.primary,
                    size: 20.w,
                  ),
                  onTap: onCreateGroup,
                ),
              ],
              child: SizedBox(
                width: Styles.controlHeight,
                height: Styles.controlHeight,
                child: Center(
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Styles.surface,
                      BlendMode.srcIn,
                    ),
                    child: ImageRes.addBlack.toImage
                      ..width = 22.w
                      ..height = 22.h,
                  ),
                ),
              ),
            ),
          ],
        );

  TitleBar.chat({
    super.key,
    String? title,
    String? member,
    bool isMultiModel = false,
    bool showCallBtn = true,
    bool isMuted = false,
    Function()? onClickCallBtn,
    Function()? onClickMoreBtn,
    Function()? onCloseMultiModel,
  })  : backgroundColor = Styles.primary,
        height = 56,
        showUnderline = true,
        centerOnScreen = false,
        center = Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (null != title)
                Text(
                  title.trim(),
                  style: Styles.ts_FFFFFF_17sp_semibold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              if (null != member && member.trim().isNotEmpty) ...[
                1.verticalSpace,
                Text(
                  member,
                  style: Styles.ts_FFFFFF_12sp.copyWith(
                    color: Styles.surface.withValues(alpha: .76),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        left = SizedBox(
            width: showCallBtn ? 92 : Styles.controlHeight,
            child: isMultiModel
                ? _TitleAction(
                    alignment: Alignment.centerLeft,
                    onTap: onCloseMultiModel,
                    child: StrRes.cancel.toText..style = Styles.ts_0C1C33_17sp,
                  )
                : _TitleAction(
                    alignment: Alignment.centerLeft,
                    onTap: () => Get.back(),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Styles.surface,
                        BlendMode.srcIn,
                      ),
                      child: ImageRes.backBlack.toImage
                        ..width = 22.w
                        ..height = 22.h,
                    ),
                  )),
        right = SizedBox(
            width: showCallBtn ? 92 : Styles.controlHeight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCallBtn)
                  _TitleAction(
                    onTap: isMuted ? null : onClickCallBtn,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Styles.surface.withValues(
                          alpha: isMuted ? .4 : 1,
                        ),
                        BlendMode.srcIn,
                      ),
                      child: ImageRes.callBack.toImage
                        ..width = 22.w
                        ..height = 22.h,
                    ),
                  ),
                if (showCallBtn) 4.horizontalSpace,
                _TitleAction(
                  onTap: onClickMoreBtn,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Styles.surface,
                      BlendMode.srcIn,
                    ),
                    child: ImageRes.moreBlack.toImage
                      ..width = 22.w
                      ..height = 22.h,
                  ),
                ),
              ],
            ));

  TitleBar.back({
    super.key,
    String? title,
    String? leftTitle,
    TextStyle? titleStyle,
    TextStyle? leftTitleStyle,
    String? result,
    Color? backgroundColor,
    Color? backIconColor,
    this.right,
    this.showUnderline = false,
    Function()? onTap,
  })  : height = Styles.controlHeight,
        backgroundColor = backgroundColor ?? Styles.c_FFFFFF,
        centerOnScreen = true,
        center = (title ?? '').toText
          ..style = (titleStyle ?? Styles.ts_0C1C33_17sp_semibold)
          ..textAlign = TextAlign.center
          ..maxLines = 1
          ..overflow = TextOverflow.ellipsis,
        left = _TitleAction(
          onTap: onTap ?? (() => Get.back(result: result)),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageRes.backBlack.toImage
                ..width = 24.w
                ..height = 24.h
                ..color = backIconColor,
              if (null != leftTitle)
                leftTitle.toText
                  ..style = (leftTitleStyle ?? Styles.ts_0C1C33_17sp_semibold),
            ],
          ),
        );

  TitleBar.contacts({
    super.key,
    this.showUnderline = false,
    Function()? onClickAddContacts,
  })  : height = 56,
        backgroundColor = Styles.primary,
        centerOnScreen = false,
        center = Spacer(),
        left = StrRes.contacts.toText..style = Styles.ts_FFFFFF_20sp_medium,
        right = Row(
          children: [
            16.horizontalSpace,
            _TitleAction(
              onTap: onClickAddContacts,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Styles.surface,
                  BlendMode.srcIn,
                ),
                child: ImageRes.addContacts.toImage
                  ..width = 22.w
                  ..height = 22.h,
              ),
            ),
          ],
        );

  TitleBar.workbench({
    super.key,
    this.showUnderline = true,
  })  : height = Styles.controlHeight,
        backgroundColor = Styles.c_FFFFFF,
        centerOnScreen = false,
        center = null,
        left = StrRes.workbench.toText..style = Styles.ts_0C1C33_20sp_semibold,
        right = null;

  TitleBar.search({
    super.key,
    String? hintText,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = true,
    Function(String)? onSubmitted,
    Function()? onCleared,
    ValueChanged<String>? onChanged,
  })  : height = Styles.controlHeight,
        backgroundColor = Styles.c_FFFFFF,
        centerOnScreen = false,
        center = Expanded(
          child: Container(
              child: SearchBox(
            enabled: true,
            autofocus: autofocus,
            hintText: hintText,
            controller: controller,
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            onCleared: onCleared,
            onChanged: onChanged,
          )),
        ),
        showUnderline = true,
        right = null,
        left = _TitleAction(
          onTap: () => Get.back(),
          alignment: Alignment.centerLeft,
          child: ImageRes.backBlack.toImage
            ..width = 24.w
            ..height = 24.h,
        );
}

class _TitleAction extends StatelessWidget {
  const _TitleAction({
    required this.child,
    this.onTap,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final VoidCallback? onTap;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(
        width: Styles.controlHeight,
        height: Styles.controlHeight,
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}
