import 'package:flutter/cupertino.dart';

import 'app_palette.dart';
import 'theme_mode_preference.dart';

class AppThemeScope extends InheritedWidget {
  const AppThemeScope({
    super.key,
    required this.preference,
    required this.brightness,
    required this.palette,
    required super.child,
  });

  final ThemeModePreference preference;
  final Brightness brightness;
  final AppPalette palette;

  static AppPalette of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope not found in widget tree');
    return scope!.palette;
  }

  static ThemeModePreference preferenceOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope not found in widget tree');
    return scope!.preference;
  }

  @override
  bool updateShouldNotify(AppThemeScope oldWidget) {
    return preference != oldWidget.preference ||
        brightness != oldWidget.brightness ||
        palette != oldWidget.palette;
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => AppThemeScope.of(this);
}
