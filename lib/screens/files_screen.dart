import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_strings.dart';
import '../helpers/tv_file_helper.dart';
import '../models/download_item.dart';
import '../services/download_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme_scope.dart';
import '../widgets/empty_state.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => FilesScreenState();
}

class FilesScreenState extends State<FilesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void refresh() => setState(() {});

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _iconForFile(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf' => CupertinoIcons.doc_text_fill,
      'zip' || 'rar' || '7z' => CupertinoIcons.archivebox_fill,
      'mp4' || 'mov' || 'm4v' => CupertinoIcons.film_fill,
      'mp3' || 'wav' || 'm4a' => CupertinoIcons.music_note_2,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' => CupertinoIcons.photo_fill,
      'apk' || 'ipa' => CupertinoIcons.app_fill,
      _ => CupertinoIcons.doc_fill,
    };
  }

  Future<void> _sendToTv(DownloadItem item) async {
    await TvFileHelper.openForFile(context, item);
  }

  Future<void> _shareFile(DownloadItem item) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(item.filePath)], text: item.fileName),
    );
  }

  Future<void> _confirmDelete(DownloadItem item) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete File?'),
        content: Text('${item.fileName} will be permanently deleted.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DownloadService.instance.delete(item);
      refresh();
    }
  }

  void _showFileActions(DownloadItem item) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(item.fileName),
        actions: [
          if (TvFileHelper.showTvShortcut(item.fileName))
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(ctx);
                _sendToTv(item);
              },
              child: Text(TvFileHelper.actionLabelForFile(item.fileName)),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _shareFile(item);
            },
            child: const Text('Share / Open With…'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDelete(item);
            },
            child: const Text('Delete'),
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
    super.build(context);
    final downloads = DownloadService.instance.downloads;
    final dateFormat = DateFormat.MMMd().add_jm();

    final palette = context.palette;

    return CupertinoPageScaffold(
      backgroundColor: palette.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text(AppStrings.filesTitle),
        backgroundColor: palette.navBarBackground,
        border: null,
      ),
      child: downloads.isEmpty
          ? const EmptyState(
              icon: CupertinoIcons.folder,
              title: 'Library is empty',
              subtitle:
                  'Saved files appear here after you download from Home or Browse.',
            )
          : CupertinoFormSection.insetGrouped(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                for (final item in downloads)
                  _FileTile(
                    item: item,
                    icon: _iconForFile(item.fileName),
                    sizeLabel: _formatSize(item.fileSizeBytes),
                    dateLabel: dateFormat.format(item.downloadedAt),
                    canSendToTv: TvFileHelper.showTvShortcut(item.fileName),
                    onTap: () => _showFileActions(item),
                    onSendToTv: () => _sendToTv(item),
                  ),
              ],
            ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.item,
    required this.icon,
    required this.sizeLabel,
    required this.dateLabel,
    required this.canSendToTv,
    required this.onTap,
    required this.onSendToTv,
  });

  final DownloadItem item;
  final IconData icon;
  final String sizeLabel;
  final String dateLabel;
  final bool canSendToTv;
  final VoidCallback onTap;
  final VoidCallback onSendToTv;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final exists = File(item.filePath).existsSync();

    return CupertinoListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: palette.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        item.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('$sizeLabel · $dateLabel${exists ? '' : ' · Missing'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canSendToTv)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: onSendToTv,
              child: const Icon(
                CupertinoIcons.tv,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          const Icon(CupertinoIcons.ellipsis, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }
}
