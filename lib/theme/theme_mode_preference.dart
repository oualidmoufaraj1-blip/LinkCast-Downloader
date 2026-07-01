enum ThemeModePreference {
  system,
  light,
  dark;

  String get label => switch (this) {
        ThemeModePreference.system => 'System',
        ThemeModePreference.light => 'Light',
        ThemeModePreference.dark => 'Dark',
      };

  static ThemeModePreference fromIndex(int index) {
    if (index < 0 || index >= ThemeModePreference.values.length) {
      return ThemeModePreference.system;
    }
    return ThemeModePreference.values[index];
  }
}
