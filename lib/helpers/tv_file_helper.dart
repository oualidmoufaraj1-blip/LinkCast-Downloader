import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';

import '../models/download_item.dart';
import '../screens/send_to_tv_screen.dart';
import '../utils/media_utils.dart';

abstract final class TvFileHelper {
  static Future<void> openForFile(BuildContext context, DownloadItem item) async {
    if (!File(item.filePath).existsSync()) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('File Missing'),
          content: const Text('This file is no longer on your device.'),
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

    switch (MediaUtils.kindForFile(item.fileName)) {
      case MediaKind.video:
      case MediaKind.audio:
        await Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => SendToTvScreen(item: item),
          ),
        );
      case MediaKind.app:
        await _showAppPackageHelp(context, item);
      case MediaKind.unsupported:
        await _showUnsupportedHelp(context, item);
    }
  }

  static Future<void> _shareFile(DownloadItem item) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(item.filePath)], text: item.fileName),
    );
  }

  static Future<void> _showAppPackageHelp(
    BuildContext context,
    DownloadItem item,
  ) async {
    final isApk = MediaUtils.isApk(item.fileName);
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(isApk ? 'APK on iPhone' : 'App Installer'),
        content: Text(
          isApk
              ? 'APK files install on Android devices and Fire TV — they cannot '
                  'be installed on iPhone or streamed via AirPlay.\n\n'
                  'To install on your TV:\n'
                  '• Open a file browser or downloader app on your TV\n'
                  '• Enter the same URL or short code\n'
                  '• Install the APK directly on the TV\n\n'
                  'You can Share this file to transfer it to a computer or Android device.'
              : 'IPA files cannot be installed from this app on iPhone or sent to a TV. '
                  'Use Share to move the file to another device if needed.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _shareFile(item);
            },
            child: const Text('Share File'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showUnsupportedHelp(
    BuildContext context,
    DownloadItem item,
  ) async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cannot Stream to TV'),
        content: Text(
          '${item.fileName} is not a video or audio file, so it cannot be '
          'streamed via AirPlay. Use Share to open it in another app.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _shareFile(item);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  static bool showTvShortcut(String fileName) =>
      MediaUtils.shouldOpenTvTabAfterDownload(fileName);

  static String actionLabelForFile(String fileName) {
    return switch (MediaUtils.kindForFile(fileName)) {
      MediaKind.video || MediaKind.audio => 'Cast',
      MediaKind.app => 'TV install guide',
      MediaKind.unsupported => 'Share',
    };
  }
}
