import 'package:flutter/cupertino.dart';

/// Semantic surface and text colors that adapt to light or dark mode.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.card,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.separator,
    required this.primaryLight,
    required this.navBarBackground,
    required this.tabBarBackground,
    required this.fieldBackground,
    required this.shadowSubtle,
  });

  final Brightness brightness;
  final Color background;
  final Color card;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color separator;
  final Color primaryLight;
  final Color navBarBackground;
  final Color tabBarBackground;
  final Color fieldBackground;
  final Color shadowSubtle;

  bool get isDark => brightness == Brightness.dark;

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF2F2F7),
    card: Color(0xFFFFFFFF),
    label: Color(0xFF000000),
    secondaryLabel: Color(0xFF8E8E93),
    tertiaryLabel: Color(0xFF8E8E93),
    separator: Color(0xFFC6C6C8),
    primaryLight: Color(0xFFFFF3E8),
    navBarBackground: Color(0xF0F9F9F9),
    tabBarBackground: Color(0xFCFFFFFF),
    fieldBackground: Color(0xFFF2F2F7),
    shadowSubtle: Color(0x0A000000),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    card: Color(0xFF1C1C1E),
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0xFF8E8E93),
    tertiaryLabel: Color(0xFF636366),
    separator: Color(0xFF38383A),
    primaryLight: Color(0xFF3D2A1A),
    navBarBackground: Color(0xF01C1C1E),
    tabBarBackground: Color(0xF01C1C1E),
    fieldBackground: Color(0xFF2C2C2E),
    shadowSubtle: Color(0x33000000),
  );

  static AppPalette of(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
