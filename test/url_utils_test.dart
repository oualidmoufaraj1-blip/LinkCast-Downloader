import 'package:flutter_test/flutter_test.dart';

import 'package:fc_app3_downloader_aftvnews/utils/url_utils.dart';

void main() {
  group('UrlUtils', () {
    test('normalizes bare domains', () {
      expect(UrlUtils.normalize('example.com'), 'https://example.com');
    });

    test('resolves short codes to aftv.news', () {
      expect(UrlUtils.normalize('12345'), 'https://aftv.news/12345');
    });

    test('detects direct file URLs', () {
      expect(
        UrlUtils.isDirectFileUrl('https://cdn.example.com/file.pdf'),
        isTrue,
      );
      expect(
        UrlUtils.isDirectFileUrl('https://example.com/page'),
        isFalse,
      );
    });

    test('search terms become Google queries', () {
      expect(
        UrlUtils.normalize('flutter downloader'),
        'https://www.google.com/search?q=flutter%20downloader',
      );
    });
  });
}
