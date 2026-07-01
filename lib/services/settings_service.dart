import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_mode_preference.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _autoOpenBrowserKey = 'auto_open_browser';
  static const _userAgentKey = 'custom_user_agent';
  static const _clearHistoryOnExitKey = 'clear_history_on_exit';
  static const _themeModeKey = 'theme_mode';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  bool get autoOpenBrowser => _prefs?.getBool(_autoOpenBrowserKey) ?? true;

  Future<void> setAutoOpenBrowser(bool value) async {
    await _prefs?.setBool(_autoOpenBrowserKey, value);
    notifyListeners();
  }

  bool get clearHistoryOnExit =>
      _prefs?.getBool(_clearHistoryOnExitKey) ?? false;

  Future<void> setClearHistoryOnExit(bool value) async {
    await _prefs?.setBool(_clearHistoryOnExitKey, value);
    notifyListeners();
  }

  ThemeModePreference get themeMode => ThemeModePreference.fromIndex(
        _prefs?.getInt(_themeModeKey) ?? ThemeModePreference.dark.index,
      );

  Future<void> setThemeMode(ThemeModePreference mode) async {
    await _prefs?.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  String get userAgent =>
      _prefs?.getString(_userAgentKey) ??
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

  Future<void> setUserAgent(String value) async {
    await _prefs?.setString(_userAgentKey, value);
    notifyListeners();
  }
}
