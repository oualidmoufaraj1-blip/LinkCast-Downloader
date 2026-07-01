import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../constants/app_strings.dart';
import '../helpers/tv_file_helper.dart';
import '../models/download_item.dart';
import '../services/download_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';
import '../utils/media_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import 'send_to_tv_help_screen.dart';

enum _TvFilter { all, video, audio, apps }

class TvScreen extends StatefulWidget {
  const TvScreen({super.key});

  @override
  State<TvScreen> createState() => TvScreenState();
}

class TvScreenState extends State<TvScreen> with AutomaticKeepAliveClientMixin {
  _TvFilter _filter = _TvFilter.all;

  @override
  bool get wantKeepAlive => true;

  void refresh() => setState(() {});

  List<DownloadItem> get _filteredFiles {
    return DownloadService.instance.downloads.where((item) {
      if (!File(item.filePath).existsSync()) return false;
      final kind = MediaUtils.kindForFile(item.fileName);
      return switch (_filter) {
        _TvFilter.all => true,
        _TvFilter.video => kind == MediaKind.video,
        _TvFilter.audio => kind == MediaKind.audio,
        _TvFilter.apps => kind == MediaKind.app,
      };
    }).toList();
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _openCast(DownloadItem item) async {
    await TvFileHelper.openForFile(context, item);
  }

  String get _emptySubtitle {
    return switch (_filter) {
      _TvFilter.all =>
        'Download media or app packages, then manage casting from this screen.',
      _TvFilter.video => 'No video files in your library yet.',
      _TvFilter.audio => 'No audio files in your library yet.',
      _TvFilter.apps => 'No app installers in your library yet.',
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final files = _filteredFiles;
    final dateFormat = DateFormat.MMMd().add_jm();

    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(AppStrings.tvTitle),
        backgroundColor: palette.navBarBackground,
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => SendToTvHelpScreen.open(context),
          child: const Icon(CupertinoIcons.question_circle),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            const _CastInfoCard(),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Filter library'),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CupertinoSlidingSegmentedControl<_TvFilter>(
                groupValue: _filter,
                backgroundColor: palette.separator.withValues(alpha: 0.5),
                thumbColor: palette.card,
                onValueChanged: (value) {
                  if (value != null) setState(() => _filter = value);
                },
                children: const {
                  _TvFilter.all: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('All'),
                  ),
                  _TvFilter.video: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('Video'),
                  ),
                  _TvFilter.audio: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('Audio'),
                  ),
                  _TvFilter.apps: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Text('Apps'),
                  ),
                },
              ),
            ),
            if (files.isEmpty)
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: EmptyState(
                  icon: CupertinoIcons.tv,
                  title: 'Nothing to cast',
                  subtitle: _emptySubtitle,
                ),
              )
            else
              CupertinoFormSection.insetGrouped(
                backgroundColor: palette.background,
                margin: EdgeInsets.zero,
                header: Text(
                  '${files.length} item${files.length == 1 ? '' : 's'}',
                  style: TextStyle(color: palette.secondaryLabel),
                ),
                children: [
                  for (final item in files)
                    _CastListTile(
                      item: item,
                      kind: MediaUtils.kindForFile(item.fileName),
                      meta:
                          '${_formatSize(item.fileSizeBytes)} · ${dateFormat.format(item.downloadedAt)}',
                      onTap: () => _openCast(item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CastInfoCard extends StatelessWidget {
  const _CastInfoCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.tv_fill, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.castFeatureTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.castFeatureSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: palette.secondaryLabel,
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

class _CastListTile extends StatelessWidget {
  const _CastListTile({
    required this.item,
    required this.kind,
    required this.meta,
    required this.onTap,
  });

  final DownloadItem item;
  final MediaKind kind;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final action = switch (kind) {
      MediaKind.video || MediaKind.audio => 'Cast',
      MediaKind.app => 'Guide',
      MediaKind.unsupported => 'Share',
    };

    return CupertinoListTile(
      leading: Icon(
        switch (kind) {
          MediaKind.video => CupertinoIcons.film,
          MediaKind.audio => CupertinoIcons.music_note_2,
          MediaKind.app => CupertinoIcons.app,
          MediaKind.unsupported => CupertinoIcons.doc,
        },
        color: AppColors.primary,
      ),
      title: Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(meta),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          action,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.labelOnDark,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
