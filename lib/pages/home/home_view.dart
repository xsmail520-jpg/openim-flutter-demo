import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../contacts/contacts_view.dart';
import '../conversation/conversation_view.dart';
import '../discover/discover_view.dart';
import '../mine/mine_view.dart';
import 'home_logic.dart';

class HomePage extends StatelessWidget {
  final logic = Get.find<HomeLogic>();
  HomePage({super.key});

  List<PersistentTabConfig> _tabs() => [
        PersistentTabConfig(
          screen: ConversationPage(),
          item: ItemConfig(
            icon: _setupIcon(
              Icons.forum_rounded,
              logic.unreadMsgCount.value,
              isActive: true,
            ),
            inactiveIcon: _setupIcon(
              Icons.forum_outlined,
              logic.unreadMsgCount.value,
              isActive: false,
            ),
            title: StrRes.home,
            activeForegroundColor: Styles.primary,
            inactiveForegroundColor: Styles.muted,
            iconSize: 22.w,
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: ContactsPage(),
          item: ItemConfig(
            icon: _setupIcon(
              Icons.contacts_rounded,
              logic.unhandledCount.value,
              isActive: true,
            ),
            inactiveIcon: _setupIcon(
              Icons.contacts_outlined,
              logic.unhandledCount.value,
              isActive: false,
            ),
            title: StrRes.contacts,
            activeForegroundColor: Styles.primary,
            inactiveForegroundColor: Styles.muted,
            iconSize: 22.w,
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: const DiscoverPage(),
          item: ItemConfig(
            icon: _setupIcon(
              Icons.explore_rounded,
              0,
              isActive: true,
            ),
            inactiveIcon: _setupIcon(
              Icons.explore_outlined,
              0,
              isActive: false,
            ),
            title: StrRes.workbench,
            activeForegroundColor: Styles.primary,
            inactiveForegroundColor: Styles.muted,
            iconSize: 22.w,
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PersistentTabConfig(
          screen: MinePage(),
          item: ItemConfig(
            icon: _setupIcon(
              Icons.person_rounded,
              0,
              isActive: true,
            ),
            inactiveIcon: _setupIcon(
              Icons.person_outline_rounded,
              0,
              isActive: false,
            ),
            title: StrRes.mine,
            activeForegroundColor: Styles.primary,
            inactiveForegroundColor: Styles.muted,
            iconSize: 22.w,
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ];

  /// 底栏统一使用同一套 Material 图标，选中实心、未选中线性。
  Widget _setupIcon(
    IconData iconData,
    int unReadCount, {
    required bool isActive,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          iconData,
          size: 23.w,
          color: isActive ? Styles.primary : Styles.muted,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Transform.translate(
            offset: const Offset(2, -2),
            child: UnreadCountView(count: unReadCount),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.background,
      body: Obx(
        () => PersistentTabView(
          tabs: _tabs(),
          navBarHeight: 64.h,
          backgroundColor: Styles.background,
          navBarBuilder: (navBarConfig) => Style1BottomNavBar(
            navBarConfig: navBarConfig,
            navBarDecoration: NavBarDecoration(
              color: Styles.surface,
              border: const BorderDirectional(
                top: BorderSide(
                  color: Styles.divider,
                  width: Styles.dividerWidth,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            ),
          ),
          navBarOverlap: const NavBarOverlap.none(),
          screenTransitionAnimation: const ScreenTransitionAnimation.none(),
        ),
      ),
    );
  }
}
