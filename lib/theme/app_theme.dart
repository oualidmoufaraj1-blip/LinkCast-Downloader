import 'package:flutter/cupertino.dart';

import 'app_colors.dart';
import 'app_palette.dart';

abstract final class AppTheme {
  static CupertinoThemeData cupertino(Brightness brightness) {
    final palette = AppPalette.of(brightness);

    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: palette.background,
      barBackgroundColor: palette.navBarBackground,
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.primary,
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: palette.label,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: palette.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: palette.label,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: palette.secondaryLabel,
        ),
      ),
    );
  }

  static const CupertinoThemeData splash = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
  );
}
