class UrlUtils {
  static String normalize(String input) {
    var trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;

    if (RegExp(r'^\d{4,8}$').hasMatch(trimmed)) {
      return 'https://aftv.news/$trimmed';
    }

    if (!trimmed.contains('://')) {
      if (trimmed.contains('.') && !trimmed.contains(' ')) {
        trimmed = 'https://$trimmed';
      } else {
        trimmed =
            'https://www.google.com/search?q=${Uri.encodeComponent(trimmed)}';
      }
    }

    return trimmed;
  }

  static bool isDirectFileUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    const extensions = [
      '.pdf', '.zip', '.apk', '.mp4', '.mp3', '.jpg', '.jpeg', '.png',
      '.gif', '.doc', '.docx', '.xls', '.xlsx', '.txt', '.json', '.xml',
      '.ipa', '.dmg', '.pkg', '.mov', '.m4v', '.wav', '.epub',
    ];
    return extensions.any(path.endsWith);
  }

  static String displayHost(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.host.isNotEmpty ? uri.host : url;
  }
}
