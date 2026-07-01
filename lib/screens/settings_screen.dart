import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_strings.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';
import '../theme/theme_mode_preference.dart';
import '../widgets/section_header.dart';
import 'privacy_policy_screen.dart';
import 'send_to_tv_help_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onHistoryCleared});

  final VoidCallback onHistoryCleared;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoOpenBrowser = SettingsService.instance.autoOpenBrowser;
  bool _clearHistoryOnExit = SettingsService.instance.clearHistoryOnExit;
  ThemeModePreference _themeMode = SettingsService.instance.themeMode;
  String _version = '…';

  @override
  void initState() {
    super.initState();
    SettingsService.instance.addListener(_onSettingsChanged);
    _loadVersion();
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (!mounted) return;
    setState(() {
      _autoOpenBrowser = SettingsService.instance.autoOpenBrowser;
      _clearHistoryOnExit = SettingsService.instance.clearHistoryOnExit;
      _themeMode = SettingsService.instance.themeMode;
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _version = '${info.version} (${info.buildNumber})');
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All recent links will be removed from Home.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.instance.clear();
      widget.onHistoryCleared();
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri.parse('mailto:${AppStrings.supportEmail}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    if (!mounted) return;
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Contact support'),
        content: Text(
          'Email us at ${AppStrings.supportEmail}\n\n'
          'Copy the address if Mail is not set up on this device.',
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
  }

  void _pickThemeMode() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Appearance'),
        message: Text('Choose how ${AppStrings.appName} looks on this device.'),
        actions: [
          for (final mode in ThemeModePreference.values)
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(ctx);
                await SettingsService.instance.setThemeMode(mode);
              },
              child: Text(
                _themeMode == mode ? '${mode.label} ✓' : mode.label,
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(AppStrings.settingsTitle),
        backgroundColor: palette.navBarBackground,
        border: null,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 120),
        children: [
          const SectionHeader(
            title: 'Appearance',
            subtitle: 'Match your device or choose a fixed theme',
          ),
          CupertinoFormSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: const Text('Theme'),
                additionalInfo: Text(_themeMode.label),
                trailing: const CupertinoListTileChevron(),
                onTap: _pickThemeMode,
              ),
            ],
          ),
          const SectionHeader(
            title: 'Browsing',
            subtitle: 'Control how links open after you tap Continue',
          ),
          CupertinoFormSection.insetGrouped(
            children: [
              CupertinoFormRow(
                prefix: const Text('Open links in browser'),
                child: CupertinoSwitch(
                  value: _autoOpenBrowser,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) async {
                    await SettingsService.instance.setAutoOpenBrowser(value);
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: const Text('Clear history on exit'),
                child: CupertinoSwitch(
                  value: _clearHistoryOnExit,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) async {
                    await SettingsService.instance.setClearHistoryOnExit(value);
                  },
                ),
              ),
            ],
          ),
          const SectionHeader(title: 'Privacy & data'),
          CupertinoFormSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: const Text('Clear recent history'),
                trailing: const CupertinoListTileChevron(),
                onTap: _clearHistory,
              ),
              CupertinoListTile(
                title: const Text('Privacy policy'),
                trailing: const CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SectionHeader(title: 'Guides'),
          CupertinoFormSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: const Text('Cast to TV guide'),
                trailing: const CupertinoListTileChevron(),
                onTap: () => SendToTvHelpScreen.open(context),
              ),
            ],
          ),
          const SectionHeader(title: 'About'),
          CupertinoFormSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: const Text('Version'),
                additionalInfo: Text(_version),
              ),
              CupertinoListTile(
                title: const Text('Contact support'),
                trailing: const CupertinoListTileChevron(),
                onTap: _openEmail,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${AppStrings.appName} · ${AppStrings.tagline}',
              style: TextStyle(
                fontSize: 13,
                color: palette.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
