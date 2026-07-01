import 'package:flutter/cupertino.dart';

/// Orange accent palette on iOS grouped surfaces.
abstract final class AppColors {
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryDark = Color(0xFFE05A00);
  static const Color primaryLight = Color(0xFFFFF3E8);
  static const Color accent = Color(0xFFFF9500);

  static const Color background = Color(0xFFF2F2F7);
  static const Color card = Color(0xFFFFFFFF);
  static const Color elevated = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF2C2C2E);

  static const Color label = Color(0xFF000000);
  static const Color secondaryLabel = Color(0xFF8E8E93);
  static const Color tertiaryLabel = Color(0xFF8E8E93);

  static const Color labelOnDark = Color(0xFFFFFFFF);
  static const Color secondaryOnDark = Color(0xFFAEAEB2);

  static const Color separator = Color(0xFFC6C6C8);
  static const Color separatorStrong = Color(0xFF38383A);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color danger = Color(0xFFFF3B30);

  static const List<Color> chipColors = [
    Color(0xFFFF6B00),
    Color(0xFFFF9500),
    Color(0xFFE05A00),
    Color(0xFF34C759),
  ];

  // Legacy aliases used by older screens.
  static const Color groupedBackground = background;
  static const Color surface = surfaceDark;
  static const Color surfaceElevated = Color(0xFF3A3A3C);
  static const Color lightLabel = label;
  static const Color lightSecondaryLabel = secondaryLabel;
  static const Color lightSeparator = separator;
}
