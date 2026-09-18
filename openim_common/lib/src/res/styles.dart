import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Styles {
  Styles._();

  // “中国红 · 宣纸白”基础令牌。历史色值字段继续作为兼容别名，确保所有
  // 已有页面和第三方组件在不改业务逻辑的前提下共享同一视觉语言。
  static const Color primary = Color(0xFFC0182B);
  static const Color primaryPressed = Color(0xFF97111F);
  static const Color primaryContainer = Color(0xFFFCECEE);
  static const Color primarySoft = Color(0xFFFFF6F6);
  static const Color gold = Color(0xFFA77B35);
  static const Color danger = Color(0xFFA80F1C);
  static const Color dangerContainer = Color(0xFFFBE9EB);
  static const Color success = Color(0xFF2F6B4F);
  static const Color warning = Color(0xFF9A6700);
  static const Color ink = Color(0xFF202124);
  static const Color muted = Color(0xFF70747C);
  static const Color divider = Color(0xFFE3E0DC);
  static const Color background = Color(0xFFF5F3F1);
  static const Color surface = Color(0xFFFFFEFC);

  static const double radiusSmall = 7;
  static const double radiusMedium = 10;
  static const double controlHeight = 44;
  static const double dividerWidth = .5;

  static Color c_0089FF = primary;
  static Color c_0C1C33 = ink;
  static Color c_8E9AB0 = muted;
  static Color c_E8EAEF = divider;
  static Color c_FF381F = danger;
  static Color c_FFFFFF = surface;
  static Color c_18E875 = success;
  static Color c_F0F2F6 = background;
  static Color c_000000 = const Color(0xFF000000); //
  static Color c_92B3E0 = const Color(0xFFC89A9F);
  static Color c_F2F8FF = primaryContainer;
  static Color c_F8F9FA = background;
  static Color c_6085B1 = muted;
  static Color c_FFB300 = gold;
  static Color c_FFE1DD = dangerContainer;
  static Color c_707070 = muted;

  static Color c_92B3E0_opacity50 = c_92B3E0.withOpacity(.5);
  static Color c_E8EAEF_opacity50 = c_E8EAEF.withOpacity(.5);
  static Color c_F4F5F7 = background;
  static Color c_CCE7FE = primaryContainer;

  static Color c_FFFFFF_opacity0 = c_FFFFFF.withOpacity(.0);
  static Color c_FFFFFF_opacity70 = c_FFFFFF.withOpacity(.7);
  static Color c_FFFFFF_opacity50 = c_FFFFFF.withOpacity(.5);
  static Color c_0089FF_opacity10 = c_0089FF.withOpacity(.1);
  static Color c_0089FF_opacity20 = c_0089FF.withOpacity(.2);
  static Color c_0089FF_opacity50 = c_0089FF.withOpacity(.5);
  static Color c_FF381F_opacity10 = c_FF381F.withOpacity(.1);
  static Color c_8E9AB0_opacity13 = c_8E9AB0.withOpacity(.13);
  static Color c_8E9AB0_opacity15 = c_8E9AB0.withOpacity(.15);
  static Color c_8E9AB0_opacity16 = c_8E9AB0.withOpacity(.16);
  static Color c_8E9AB0_opacity30 = c_8E9AB0.withOpacity(.3);
  static Color c_8E9AB0_opacity50 = c_8E9AB0.withOpacity(.5);
  static Color c_0C1C33_opacity30 = c_0C1C33.withOpacity(.3);
  static Color c_0C1C33_opacity60 = c_0C1C33.withOpacity(.6);
  static Color c_0C1C33_opacity85 = c_0C1C33.withOpacity(.85);
  static Color c_0C1C33_opacity80 = c_0C1C33.withOpacity(.8);
  static Color c_FF381F_opacity70 = c_FF381F.withOpacity(.7);
  static Color c_000000_opacity70 = c_000000.withOpacity(.7);
  static Color c_000000_opacity15 = c_000000.withOpacity(.15);
  static Color c_000000_opacity12 = c_000000.withOpacity(.12);
  static Color c_000000_opacity4 = c_000000.withOpacity(.04);

  static TextStyle ts_FFFFFF_21sp = TextStyle(
    color: c_FFFFFF,
    fontSize: 21.sp,
  );
  static TextStyle ts_FFFFFF_20sp_medium = TextStyle(
    color: c_FFFFFF,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_FFFFFF_18sp_medium = TextStyle(
    color: c_FFFFFF,
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_FFFFFF_17sp = TextStyle(
    color: c_FFFFFF,
    fontSize: 17.sp,
  );
  static TextStyle ts_FFFFFF_opacity70_17sp = TextStyle(
    color: c_FFFFFF_opacity70,
    fontSize: 17.sp,
  );
  static TextStyle ts_FFFFFF_17sp_semibold = TextStyle(
    color: c_FFFFFF,
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle ts_FFFFFF_17sp_medium = TextStyle(
    color: c_FFFFFF,
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_FFFFFF_16sp = TextStyle(
    color: c_FFFFFF,
    fontSize: 16.sp,
  );
  static TextStyle ts_FFFFFF_14sp = TextStyle(
    color: c_FFFFFF,
    fontSize: 14.sp,
  );
  static TextStyle ts_FFFFFF_opacity70_14sp = TextStyle(
    color: c_FFFFFF_opacity70,
    fontSize: 14.sp,
  );
  static TextStyle ts_FFFFFF_14sp_medium = TextStyle(
    color: c_FFFFFF,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_FFFFFF_12sp = TextStyle(
    color: c_FFFFFF,
    fontSize: 12.sp,
  );
  static TextStyle ts_FFFFFF_10sp = TextStyle(
    color: c_FFFFFF,
    fontSize: 10.sp,
  );

  static TextStyle ts_8E9AB0_10sp_semibold = TextStyle(
    color: c_8E9AB0,
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle ts_8E9AB0_10sp = TextStyle(
    color: c_8E9AB0,
    fontSize: 10.sp,
  );
  static TextStyle ts_8E9AB0_12sp = TextStyle(
    color: c_8E9AB0,
    fontSize: 12.sp,
  );
  static TextStyle ts_8E9AB0_13sp = TextStyle(
    color: c_8E9AB0,
    fontSize: 13.sp,
  );
  static TextStyle ts_8E9AB0_14sp = TextStyle(
    color: c_8E9AB0,
    fontSize: 14.sp,
  );
  static TextStyle ts_8E9AB0_15sp = TextStyle(
    color: c_8E9AB0,
    fontSize: 15.sp,
  );
  static TextStyle ts_8E9AB0_16sp = TextStyle(
    color: c_8E9AB0,
    fontSize: 16.sp,
  );
  static TextStyle ts_8E9AB0_17sp = TextStyle(
    color: c_8E9AB0,
    fontSize: 17.sp,
  );
  static TextStyle ts_8E9AB0_opacity50_17sp = TextStyle(
    color: c_8E9AB0_opacity50,
    fontSize: 17.sp,
  );

  static TextStyle ts_0C1C33_10sp = TextStyle(
    color: c_0C1C33,
    fontSize: 10.sp,
  );
  static TextStyle ts_0C1C33_12sp = TextStyle(
    color: c_0C1C33,
    fontSize: 12.sp,
  );
  static TextStyle ts_0C1C33_12sp_medium = TextStyle(
    color: c_0C1C33,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_0C1C33_14sp = TextStyle(
    color: c_0C1C33,
    fontSize: 14.sp,
  );
  static TextStyle ts_0C1C33_14sp_medium = TextStyle(
    color: c_0C1C33,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_0C1C33_17sp = TextStyle(
    color: c_0C1C33,
    fontSize: 17.sp,
  );
  static TextStyle ts_0C1C33_17sp_medium = TextStyle(
    color: c_0C1C33,
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_0C1C33_17sp_semibold = TextStyle(
    color: c_0C1C33,
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle ts_0C1C33_20sp = TextStyle(
    color: c_0C1C33,
    fontSize: 20.sp,
  );
  static TextStyle ts_0C1C33_20sp_medium = TextStyle(
    color: c_0C1C33,
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_0C1C33_20sp_semibold = TextStyle(
    color: c_0C1C33,
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle ts_0089FF_10sp_semibold = TextStyle(
    color: c_0089FF,
    fontSize: 10.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle ts_0089FF_10sp = TextStyle(
    color: c_0089FF,
    fontSize: 10.sp,
  );
  static TextStyle ts_0089FF_12sp = TextStyle(
    color: c_0089FF,
    fontSize: 12.sp,
  );
  static TextStyle ts_0089FF_14sp = TextStyle(
    color: c_0089FF,
    fontSize: 14.sp,
  );
  static TextStyle ts_0089FF_16sp = TextStyle(
    color: c_0089FF,
    fontSize: 16.sp,
  );
  static TextStyle ts_0089FF_16sp_medium = TextStyle(
    color: c_0089FF,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_0089FF_17sp = TextStyle(
    color: c_0089FF,
    fontSize: 17.sp,
  );
  static TextStyle ts_0089FF_17sp_semibold = TextStyle(
    color: c_0089FF,
    fontSize: 17.sp,
    fontWeight: FontWeight.w600,
  );
  static TextStyle ts_0089FF_17sp_medium = TextStyle(
    color: c_0089FF,
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_0089FF_14sp_medium = TextStyle(
    color: c_0089FF,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle ts_0089FF_22sp_semibold = TextStyle(
    color: c_0089FF,
    fontSize: 22.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle ts_FF381F_17sp = TextStyle(
    color: c_FF381F,
    fontSize: 17.sp,
  );
  static TextStyle ts_FF381F_14sp = TextStyle(
    color: c_FF381F,
    fontSize: 14.sp,
  );
  static TextStyle ts_FF381F_12sp = TextStyle(
    color: c_FF381F,
    fontSize: 12.sp,
  );
  static TextStyle ts_FF381F_10sp = TextStyle(
    color: c_FF381F,
    fontSize: 10.sp,
  );

  static TextStyle ts_6085B1_17sp_medium = TextStyle(
    color: c_6085B1,
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
  );
  static TextStyle ts_6085B1_17sp = TextStyle(
    color: c_6085B1,
    fontSize: 17.sp,
  );
  static TextStyle ts_6085B1_12sp = TextStyle(
    color: c_6085B1,
    fontSize: 12.sp,
  );
  static TextStyle ts_6085B1_14sp = TextStyle(
    color: c_6085B1,
    fontSize: 14.sp,
  );
}
