import 'package:flutter/cupertino.dart';

import 'constants/app_strings.dart';
import 'services/download_service.dart';
import 'services/favorites_service.dart';
import 'services/history_service.dart';
import 'services/settings_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'theme/app_theme_scope.dart';
import 'theme/theme_mode_preference.dart';
import 'screens/browser_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/files_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tv_screen.dart';
import 'widgets/download_progress_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LinkCastApp());
}

class LinkCastApp extends StatefulWidget {
  const LinkCastApp({super.key});

  @override
  State<LinkCastApp> createState() => _LinkCastAppState();
}

class _LinkCastAppState extends State<LinkCastApp> with WidgetsBindingObserver {
  bool _showSplash = true;
  bool _initialized = false;
  int _currentTab = 0;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _browserKey = GlobalKey<BrowserScreenState>();
  final _filesKey = GlobalKey<FilesScreenState>();
  final _tvKey = GlobalKey<TvScreenState>();
  final _favoritesKey = GlobalKey<FavoritesScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SettingsService.instance.addListener(_onSettingsChanged);
    _initServices();
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (SettingsService.instance.themeMode == ThemeModePreference.system) {
      setState(() {});
    }
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached &&
        SettingsService.instance.clearHistoryOnExit) {
      HistoryService.instance.clear();
    }
  }

  Future<void> _initServices() async {
    await Future.wait([
      SettingsService.instance.init(),
      FavoritesService.instance.init(),
      HistoryService.instance.init(),
      DownloadService.instance.init(),
    ]);
    if (mounted) setState(() => _initialized = true);
  }

  Brightness _resolveBrightness() {
    return switch (SettingsService.instance.themeMode) {
      ThemeModePreference.light => Brightness.light,
      ThemeModePreference.dark => Brightness.dark,
      ThemeModePreference.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
  }

  void _setTab(int index) {
    setState(() => _currentTab = index);
    switch (index) {
      case 0:
        _homeKey.currentState?.refresh();
      case 2:
        _filesKey.currentState?.refresh();
      case 3:
        _tvKey.currentState?.refresh();
      case 4:
        _favoritesKey.currentState?.refresh();
    }
  }

  void _openTvTab() {
    _tvKey.currentState?.refresh();
    _setTab(3);
  }

  void _openFilesTab() {
    _filesKey.currentState?.refresh();
    _setTab(2);
  }

  void _openUrl(String url) {
    _browserKey.currentState?.loadUrl(url);
    _setTab(1);
  }

  void _onDownloadComplete({bool openTvTab = false}) {
    _filesKey.currentState?.refresh();
    _tvKey.currentState?.refresh();
    _setTab(openTvTab ? 3 : 2);
  }

  void _refreshFavorites() => _favoritesKey.currentState?.refresh();

  void _onSplashFinished() {
    if (_initialized) {
      setState(() => _showSplash = false);
    } else {
      _initServices().then((_) {
        if (mounted) setState(() => _showSplash = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themePreference = SettingsService.instance.themeMode;
    final brightness = _showSplash ? Brightness.dark : _resolveBrightness();
    final palette = AppPalette.of(brightness);

    return CupertinoApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: _showSplash ? AppTheme.splash : AppTheme.cupertino(brightness),
      builder: (context, child) {
        return AppThemeScope(
          preference: themePreference,
          brightness: brightness,
          palette: palette,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _showSplash || !_initialized
          ? SplashScreen(onFinished: _onSplashFinished)
          : _MainShell(
              currentTab: _currentTab,
              onTabChanged: _setTab,
              homeKey: _homeKey,
              browserKey: _browserKey,
              filesKey: _filesKey,
              tvKey: _tvKey,
              favoritesKey: _favoritesKey,
              onOpenUrl: _openUrl,
              onOpenTvTab: _openTvTab,
              onOpenFilesTab: _openFilesTab,
              onDownloadComplete: _onDownloadComplete,
              onFavoriteAdded: _refreshFavorites,
              onHistoryCleared: () => _homeKey.currentState?.refresh(),
            ),
    );
  }
}

class _MainShell extends StatelessWidget {
  const _MainShell({
    required this.currentTab,
    required this.onTabChanged,
    required this.homeKey,
    required this.browserKey,
    required this.filesKey,
    required this.tvKey,
    required this.favoritesKey,
    required this.onOpenUrl,
    required this.onOpenTvTab,
    required this.onOpenFilesTab,
    required this.onDownloadComplete,
    required this.onFavoriteAdded,
    required this.onHistoryCleared,
  });

  final int currentTab;
  final ValueChanged<int> onTabChanged;
  final GlobalKey<HomeScreenState> homeKey;
  final GlobalKey<BrowserScreenState> browserKey;
  final GlobalKey<FilesScreenState> filesKey;
  final GlobalKey<TvScreenState> tvKey;
  final GlobalKey<FavoritesScreenState> favoritesKey;
  final void Function(String url) onOpenUrl;
  final VoidCallback onOpenTvTab;
  final VoidCallback onOpenFilesTab;
  final void Function({bool openTvTab}) onDownloadComplete;
  final VoidCallback onFavoriteAdded;
  final VoidCallback onHistoryCleared;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      child: Column(
        children: [
          const DownloadProgressBanner(),
          Expanded(
            child: IndexedStack(
              index: currentTab,
              children: [
                HomeScreen(
                  key: homeKey,
                  onOpenUrl: onOpenUrl,
                  onOpenTvTab: onOpenTvTab,
                  onOpenFilesTab: onOpenFilesTab,
                  onDownloadComplete: onDownloadComplete,
                ),
                BrowserScreen(
                  key: browserKey,
                  onDownloadComplete: onDownloadComplete,
                  onFavoriteAdded: onFavoriteAdded,
                ),
                FilesScreen(key: filesKey),
                TvScreen(key: tvKey),
                FavoritesScreen(
                  key: favoritesKey,
                  onOpenUrl: onOpenUrl,
                ),
                SettingsScreen(onHistoryCleared: onHistoryCleared),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.separator)),
              color: palette.tabBarBackground,
            ),
            child: SafeArea(
              top: false,
              child: CupertinoTabBar(
                currentIndex: currentTab,
                activeColor: AppColors.primary,
                inactiveColor: palette.tertiaryLabel,
                backgroundColor: const Color(0x00000000),
                onTap: onTabChanged,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.house_alt),
                    activeIcon: Icon(CupertinoIcons.house_alt_fill),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.compass),
                    activeIcon: Icon(CupertinoIcons.compass_fill),
                    label: 'Browse',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.tray),
                    activeIcon: Icon(CupertinoIcons.tray_fill),
                    label: 'Library',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.tv),
                    activeIcon: Icon(CupertinoIcons.tv_fill),
                    label: 'Cast',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.bookmark),
                    activeIcon: Icon(CupertinoIcons.bookmark_fill),
                    label: 'Saved',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.slider_horizontal_3),
                    activeIcon: Icon(CupertinoIcons.slider_horizontal_3),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
