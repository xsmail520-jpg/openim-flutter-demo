import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'core/controller/im_controller.dart';
import 'core/network_route/network_route_controller.dart';
import 'routes/app_pages.dart';
import 'widgets/app_view.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppView(
      builder: (locale, builder) => GetMaterialApp(
        title: '追逐梦',
        debugShowCheckedModeBanner: false,
        enableLog: true,
        builder: builder,
        translations: TranslationService(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        fallbackLocale: TranslationService.fallbackLocale,
        locale: locale,
        localeResolutionCallback: (locale, list) {
          Get.locale ??= locale;
          return locale;
        },
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('zh', 'TW'),
          Locale('en', 'US'),
          Locale('vi', 'VN'),
        ],
        getPages: AppPages.routes,
        initialBinding: InitBinding(),
        initialRoute: AppRoutes.splash,
        theme: _themeData,
      ),
    );
  }

  ThemeData get _themeData {
    final base = ThemeData.light(useMaterial3: false);
    final colorScheme = const ColorScheme.light(
      primary: Styles.primary,
      onPrimary: Styles.surface,
      secondary: Styles.primary,
      onSecondary: Styles.surface,
      error: Styles.danger,
      onError: Styles.surface,
      surface: Styles.surface,
      onSurface: Styles.ink,
      outline: Styles.divider,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Styles.background,
      canvasColor: Styles.surface,
      cardColor: Styles.surface,
      dividerColor: Styles.divider,
      disabledColor: Styles.muted.withValues(alpha: .45),
      splashColor: Styles.primary.withValues(alpha: .06),
      highlightColor: Styles.primary.withValues(alpha: .04),
      textTheme: base.textTheme.copyWith(
        headlineSmall: TextStyle(
          color: Styles.ink,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: Styles.ink,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          color: Styles.ink,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        bodyLarge: TextStyle(
          color: Styles.ink,
          fontSize: 17.sp,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: Styles.ink,
          fontSize: 14.sp,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: Styles.muted,
          fontSize: 12.sp,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: Styles.ink,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: Styles.muted,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Styles.surface,
        foregroundColor: Styles.ink,
        surfaceTintColor: Styles.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 44.h,
        titleTextStyle: TextStyle(
          color: Styles.ink,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Styles.ink, size: 24),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Styles.primary,
        selectionColor: Styles.primary.withValues(alpha: .18),
        selectionHandleColor: Styles.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Styles.surface,
        hintStyle: TextStyle(color: Styles.muted, fontSize: 16.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          borderSide: const BorderSide(color: Styles.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          borderSide: const BorderSide(color: Styles.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          borderSide: const BorderSide(color: Styles.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          borderSide: const BorderSide(color: Styles.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
          borderSide: const BorderSide(color: Styles.danger),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Styles.surface),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Styles.divider;
          }
          if (states.contains(WidgetState.selected)) {
            return Styles.primary;
          }
          return Styles.surface;
        }),
        side: const BorderSide(color: Styles.muted, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return Styles.divider;
          }
          return states.contains(WidgetState.selected)
              ? Styles.primary
              : Styles.muted;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Styles.surface
              : Styles.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Styles.primary
              : Styles.divider;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Styles.surface,
        surfaceTintColor: Styles.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Styles.radiusMedium.r),
          side: const BorderSide(
              color: Styles.divider, width: Styles.dividerWidth),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Styles.surface,
        modalBackgroundColor: Styles.surface,
        surfaceTintColor: Styles.surface,
        elevation: 1,
        modalElevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Styles.radiusMedium.r),
          ),
          side: const BorderSide(
              color: Styles.divider, width: Styles.dividerWidth),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Styles.divider,
        thickness: Styles.dividerWidth,
        space: Styles.dividerWidth,
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(44.w, 44.h)),
          padding:
              WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14.w)),
          foregroundColor: const WidgetStatePropertyAll(Styles.primary),
          overlayColor:
              WidgetStatePropertyAll(Styles.primary.withValues(alpha: .06)),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(44.w, 44.h)),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? Styles.divider
                : Styles.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? Styles.muted
                : Styles.surface;
          }),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(44.w, 44.h)),
          foregroundColor: const WidgetStatePropertyAll(Styles.primary),
          side: const WidgetStatePropertyAll(BorderSide(color: Styles.primary)),
          textStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Styles.radiusSmall.r),
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(44.w, 44.h)),
          foregroundColor: const WidgetStatePropertyAll(Styles.ink),
          overlayColor:
              WidgetStatePropertyAll(Styles.primary.withValues(alpha: .06)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Styles.surface,
        surfaceTintColor: Styles.surface,
        elevation: 1,
        textStyle: TextStyle(color: Styles.ink, fontSize: 16.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Styles.radiusMedium.r),
          side: const BorderSide(
              color: Styles.divider, width: Styles.dividerWidth),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Styles.surface,
        selectedItemColor: Styles.primary,
        unselectedItemColor: Styles.muted,
        selectedLabelStyle:
            TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Styles.primary,
        linearTrackColor: Styles.divider,
        circularTrackColor: Styles.divider,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Styles.ink,
        contentTextStyle: TextStyle(color: Styles.surface, fontSize: 14.sp),
        actionTextColor: Styles.surface,
        elevation: 0,
        behavior: SnackBarBehavior.fixed,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Styles.primary,
        barBackgroundColor: Styles.surface,
        scaffoldBackgroundColor: Styles.background,
        applyThemeToAll: true,
        textTheme: CupertinoTextThemeData(
          navActionTextStyle: TextStyle(color: Styles.ink, fontSize: 17.sp),
          actionTextStyle: TextStyle(color: Styles.primary, fontSize: 17.sp),
          textStyle: TextStyle(color: Styles.ink, fontSize: 17.sp),
          navLargeTitleTextStyle: TextStyle(
            color: Styles.ink,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
          navTitleTextStyle: TextStyle(
            color: Styles.ink,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
          pickerTextStyle: TextStyle(color: Styles.ink, fontSize: 17.sp),
          tabLabelTextStyle: TextStyle(color: Styles.ink, fontSize: 14.sp),
          dateTimePickerTextStyle:
              TextStyle(color: Styles.ink, fontSize: 17.sp),
        ),
      ),
    );
  }
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<NetworkRouteController>(NetworkRouteController());
    Get.put<IMController>(IMController());
    Get.put<PushController>(PushController());
    Get.put<CacheController>(CacheController());
  }
}
