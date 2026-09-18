import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class ChatToolBox extends StatelessWidget {
  const ChatToolBox({
    super.key,
    this.onTapAlbum,
    this.onTapCamera,
    this.onTapEmoji,
    this.onTapCall,
    this.onTapVoice,
    this.onTapFavorite,
  });
  final Function()? onTapAlbum;
  final Function()? onTapCamera;
  final Function()? onTapEmoji;
  final Function()? onTapCall;
  final Function()? onTapVoice;
  final Function()? onTapFavorite;

  /// 统一聊天附件入口的图标、尺寸和权限触发方式。
  @override
  Widget build(BuildContext context) {
    final items = [
      ToolboxItemInfo(
        text: StrRes.toolboxAlbum,
        icon: Icons.photo_outlined,
        onTap: () => Permissions.photos(onTapAlbum),
      ),
      ToolboxItemInfo(
        text: StrRes.toolboxCamera,
        icon: Icons.camera_alt_outlined,
        onTap: () => Permissions.camera(onTapCamera),
      ),
      ToolboxItemInfo(
        text: StrRes.toolboxEmoji,
        icon: Icons.emoji_emotions_outlined,
        onTap: onTapEmoji,
      ),
      ToolboxItemInfo(
        text: StrRes.toolboxVoice,
        icon: Icons.mic_none_rounded,
        onTap: () => Permissions.microphone(onTapVoice),
      ),
      ToolboxItemInfo(
        text: StrRes.favorite,
        icon: Icons.star_border_rounded,
        onTap: onTapFavorite,
      ),
      if (onTapCall != null)
        ToolboxItemInfo(
          text: StrRes.toolboxCall,
          icon: Icons.call_outlined,
          onTap: () => Permissions.cameraAndMicrophone(onTapCall),
        ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Styles.background,
        border: Border(
          top: BorderSide(
            color: Styles.divider,
            width: Styles.dividerWidth,
          ),
        ),
      ),
      height: 224.h,
      child: GridView.builder(
        itemCount: items.length,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 6.h,
          bottom: 6.h,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 78.w / 105.h,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 2.h,
        ),
        itemBuilder: (_, index) {
          final item = items.elementAt(index);
          return _buildItemView(
            icon: item.icon,
            text: item.text,
            onTap: item.onTap,
          );
        },
      ),
    );
  }

  Widget _buildItemView({
    required String text,
    required IconData icon,
    Function()? onTap,
  }) =>
      Column(
        children: [
          Material(
            color: Styles.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: const BorderSide(color: Styles.divider),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 58.w,
                height: 58.h,
                child: Icon(icon, size: 28.w, color: Styles.primary),
              ),
            ),
          ),
          10.verticalSpace,
          text.toText..style = Styles.ts_0C1C33_12sp,
        ],
      );
}

class ToolboxItemInfo {
  final String text;
  final IconData icon;
  final Function()? onTap;

  ToolboxItemInfo({required this.text, required this.icon, this.onTap});
}
