enum MediaKind { video, audio, app, unsupported }

abstract final class MediaUtils {
  static const _videoExtensions = {
    'mp4', 'mov', 'm4v', 'avi', 'mkv', 'webm', 'm3u8', 'ts',
  };

  static const _audioExtensions = {
    'mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg', 'aiff', 'caf',
  };

  static const _appExtensions = {'apk', 'ipa', 'xapk'};

  static MediaKind kindForFile(String fileName) {
    final ext = _extension(fileName);
    if (_videoExtensions.contains(ext)) return MediaKind.video;
    if (_audioExtensions.contains(ext)) return MediaKind.audio;
    if (_appExtensions.contains(ext)) return MediaKind.app;
    return MediaKind.unsupported;
  }

  /// True when the file can be streamed to a TV via AirPlay.
  static bool canAirPlayToTv(String fileName) {
    final kind = kindForFile(fileName);
    return kind == MediaKind.video || kind == MediaKind.audio;
  }

  /// Backward-compatible alias.
  static bool canSendToTv(String fileName) => canAirPlayToTv(fileName);

  static bool isAppPackage(String fileName) =>
      kindForFile(fileName) == MediaKind.app;

  static bool isApk(String fileName) => _extension(fileName) == 'apk';

  /// Shown on the TV tab after download (media + app installers).
  static bool shouldOpenTvTabAfterDownload(String fileName) =>
      canAirPlayToTv(fileName) || isAppPackage(fileName);

  static String _extension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}
