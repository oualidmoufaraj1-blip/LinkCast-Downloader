import 'package:http/http.dart' as http;

import '../services/settings_service.dart';
import '../utils/url_utils.dart';

class UrlResolver {
  UrlResolver._();

  static const _timeout = Duration(seconds: 30);

  /// Normalizes input and follows HTTP redirects (e.g. aftv.news short codes).
  static Future<String> resolve(String input) async {
    final normalized = UrlUtils.normalize(input);
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme) return normalized;

    try {
      final client = http.Client();
      try {
        final request = http.Request('HEAD', uri)
          ..headers['User-Agent'] = SettingsService.instance.userAgent
          ..followRedirects = false;

        var response = await client.send(request).timeout(_timeout);
        var current = uri;

        for (var i = 0; i < 10; i++) {
          if (response.statusCode < 300 || response.statusCode >= 400) break;
          final location = response.headers['location'];
          if (location == null || location.isEmpty) break;
          current = current.resolve(location);
          response = await client
              .send(
                http.Request('HEAD', current)
                  ..headers['User-Agent'] = SettingsService.instance.userAgent
                  ..followRedirects = false,
              )
              .timeout(_timeout);
        }

        return current.toString();
      } on http.ClientException {
        final response = await http
            .get(
              uri,
              headers: {'User-Agent': SettingsService.instance.userAgent},
            )
            .timeout(_timeout);
        return response.request?.url.toString() ?? normalized;
      } finally {
        client.close();
      }
    } catch (_) {
      return normalized;
    }
  }
}
