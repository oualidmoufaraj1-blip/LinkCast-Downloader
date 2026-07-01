import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../constants/app_strings.dart';
import '../services/download_service.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';
import '../services/url_resolver.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';
import '../theme/theme_mode_preference.dart';
import '../utils/media_utils.dart';
import '../utils/url_utils.dart';
import '../widgets/primary_button.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenUrl,
    required this.onDownloadComplete,
    required this.onOpenTvTab,
    required this.onOpenFilesTab,
  });

  final void Function(String url) onOpenUrl;
  final void Function({bool openTvTab}) onDownloadComplete;
  final VoidCallback onOpenTvTab;
  final VoidCallback onOpenFilesTab;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;

  void refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    HistoryService.instance.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    HistoryService.instance.removeListener(_onHistoryChanged);
    _urlController.dispose();
    super.dispose();
  }

  void _onHistoryChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleContinue() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) {
      HapticFeedback.mediumImpact();
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Enter a link'),
          content: const Text(AppStrings.emptyUrlMessage),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final resolved = await UrlResolver.resolve(input);
      await HistoryService.instance.add(resolved);

      if (UrlUtils.isDirectFileUrl(resolved)) {
        await _downloadFile(resolved);
      } else if (SettingsService.instance.autoOpenBrowser) {
        widget.onOpenUrl(resolved);
      } else {
        final open = await _confirmOpenBrowser(resolved);
        if (open == true) widget.onOpenUrl(resolved);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        refresh();
      }
    }
  }

  Future<void> _downloadFile(String url) async {
    try {
      final item = await DownloadService.instance.downloadFromUrl(url);
      widget.onDownloadComplete(
        openTvTab: MediaUtils.shouldOpenTvTabAfterDownload(item.fileName),
      );
      if (!mounted) return;
      final onTvTab = MediaUtils.shouldOpenTvTabAfterDownload(item.fileName);
      final isApk = MediaUtils.isApk(item.fileName);
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text(AppStrings.savedToLibraryTitle),
          content: Text(
            isApk
                ? AppStrings.savedToLibraryApk(AppStrings.tvTitle)
                : onTvTab
                    ? AppStrings.savedToLibraryCast(AppStrings.tvTitle)
                    : AppStrings.savedToLibraryFiles(AppStrings.filesTitle),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is DownloadException ? e.message : e.toString();
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Download Failed'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool?> _confirmOpenBrowser(String url) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Open in Browser?'),
        content: Text(UrlUtils.displayHost(url)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDarkMode() async {
    HapticFeedback.selectionClick();
    final isDark = context.palette.isDark;
    await SettingsService.instance.setThemeMode(
      isDark ? ThemeModePreference.light : ThemeModePreference.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = HistoryService.instance.entries;
    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(AppStrings.homeTitle),
        backgroundColor: palette.navBarBackground,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _toggleDarkMode,
          child: Icon(
            palette.isDark
                ? CupertinoIcons.sun_max_fill
                : CupertinoIcons.moon_fill,
            color: AppColors.primary,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            const _WelcomeCard(),
            const SizedBox(height: 20),
            const SectionHeader(
              title: 'New download',
              subtitle: 'Enter a web address or search term below',
            ),
            CupertinoFormSection.insetGrouped(
              backgroundColor: palette.background,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              children: [
                CupertinoTextField(
                  controller: _urlController,
                  placeholder: AppStrings.urlPlaceholder,
                  placeholderStyle: TextStyle(color: palette.tertiaryLabel),
                  style: TextStyle(fontSize: 16, color: palette.label),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  decoration: null,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _handleContinue(),
                  autocorrect: false,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppStrings.shortCodeHint,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: palette.secondaryLabel,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: AppStrings.primaryAction,
              icon: CupertinoIcons.arrow_right_circle_fill,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleContinue,
            ),
            const SizedBox(height: 28),
            const SectionHeader(title: 'Quick actions'),
            Row(
              children: [
                QuickActionTile(
                  icon: CupertinoIcons.globe,
                  label: 'Browse',
                  color: AppColors.chipColors[0],
                  onTap: () => widget.onOpenUrl('https://www.google.com'),
                ),
                const SizedBox(width: 10),
                QuickActionTile(
                  icon: CupertinoIcons.folder_fill,
                  label: 'Library',
                  color: AppColors.chipColors[1],
                  onTap: widget.onOpenFilesTab,
                ),
                const SizedBox(width: 10),
                QuickActionTile(
                  icon: CupertinoIcons.tv_fill,
                  label: 'Cast',
                  color: AppColors.chipColors[2],
                  onTap: widget.onOpenTvTab,
                ),
              ],
            ),
            if (history.isNotEmpty) ...[
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Recent activity',
                trailing: Text(
                  '${history.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.secondaryLabel,
                  ),
                ),
              ),
              CupertinoFormSection.insetGrouped(
                backgroundColor: palette.background,
                margin: EdgeInsets.zero,
                children: [
                  for (final entry in history)
                    CupertinoListTile(
                      leading: const Icon(
                        CupertinoIcons.clock,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      title: Text(
                        entry.title ?? UrlUtils.displayHost(entry.url),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        entry.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        _urlController.text = entry.url;
                        _handleContinue();
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF6B00),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.labelOnDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.tagline,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.labelOnDark.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.labelOnDark.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.tv_fill,
                  size: 18,
                  color: AppColors.labelOnDark.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.castFeatureSubtitle,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.labelOnDark.withValues(alpha: 0.92),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
