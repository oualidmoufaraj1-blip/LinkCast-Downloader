import 'package:flutter_test/flutter_test.dart';

import 'package:fc_app3_downloader_aftvnews/utils/media_utils.dart';

void main() {
  group('MediaUtils', () {
    test('detects video files', () {
      expect(MediaUtils.kindForFile('movie.mp4'), MediaKind.video);
      expect(MediaUtils.canSendToTv('clip.mov'), isTrue);
    });

    test('detects audio files', () {
      expect(MediaUtils.kindForFile('song.mp3'), MediaKind.audio);
      expect(MediaUtils.canSendToTv('track.m4a'), isTrue);
    });

    test('detects app packages including apk', () {
      expect(MediaUtils.kindForFile('app.apk'), MediaKind.app);
      expect(MediaUtils.isApk('installer.apk'), isTrue);
      expect(MediaUtils.shouldOpenTvTabAfterDownload('app.apk'), isTrue);
      expect(MediaUtils.canAirPlayToTv('app.apk'), isFalse);
    });

    test('rejects unsupported files for airplay', () {
      expect(MediaUtils.kindForFile('doc.pdf'), MediaKind.unsupported);
      expect(MediaUtils.canSendToTv('archive.zip'), isFalse);
      expect(MediaUtils.shouldOpenTvTabAfterDownload('archive.zip'), isFalse);
    });
  });
}
