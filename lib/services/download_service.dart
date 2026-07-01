import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/download_item.dart';
import 'download_progress.dart';
import 'settings_service.dart';

class DownloadException implements Exception {
  DownloadException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DownloadService {
  DownloadService._();
  static final DownloadService instance = DownloadService._();

  static const _storageKey = 'downloads';
  static const _timeout = Duration(minutes: 10);
  static const _maxBytes = 512 * 1024 * 1024; // 512 MB

  SharedPreferences? _prefs;
  List<DownloadItem> _downloads = [];
  Directory? _downloadDir;

  List<DownloadItem> get downloads => List.unmodifiable(_downloads);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _downloadDir = await _resolveDownloadDirectory();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _downloads = list
          .map((e) => DownloadItem.fromJson(e as Map<String, dynamic>))
          .where((d) => File(d.filePath).existsSync())
          .toList();
      await _persist();
    }
  }

  Future<Directory> getDownloadDirectory() async {
    return _downloadDir ??= await _resolveDownloadDirectory();
  }

  Future<Directory> _resolveDownloadDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/Downloader');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<DownloadItem> downloadFromUrl(String url) async {
    final uri = Uri.parse(url);
    final client = http.Client();

    try {
      final request = http.Request('GET', uri)
        ..headers['User-Agent'] = SettingsService.instance.userAgent;

      final response = await client.send(request).timeout(_timeout);

      if (response.statusCode != 200) {
        throw DownloadException(
          'Download failed (HTTP ${response.statusCode})',
        );
      }

      final contentLength = response.contentLength ?? 0;
      if (contentLength > _maxBytes) {
        throw DownloadException('File exceeds the 512 MB limit');
      }

      final fileName = _uniqueFileName(
        _extractFileName(response.request?.url ?? uri, response),
      );

      DownloadProgress.instance.start(fileName);

      final dir = _downloadDir ?? await _resolveDownloadDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      final sink = file.openWrite();

      var received = 0;
      try {
        await for (final chunk in response.stream) {
          received += chunk.length;
          if (received > _maxBytes) {
            throw DownloadException('File exceeds the 512 MB limit');
          }
          sink.add(chunk);
          if (contentLength > 0) {
            DownloadProgress.instance.update(received / contentLength);
          }
        }
      } finally {
        await sink.close();
      }

      final mimeType = lookupMimeType(fileName) ??
          response.headers['content-type']?.split(';').first.trim();

      final item = DownloadItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: fileName,
        filePath: filePath,
        sourceUrl: url,
        downloadedAt: DateTime.now(),
        fileSizeBytes: received,
        mimeType: mimeType,
      );

      _downloads.insert(0, item);
      await _persist();
      return item;
    } on DownloadException {
      rethrow;
    } on SocketException {
      throw DownloadException('No internet connection');
    } on http.ClientException {
      throw DownloadException('Could not reach the server');
    } catch (e) {
      throw DownloadException('Download failed: $e');
    } finally {
      client.close();
      DownloadProgress.instance.finish();
    }
  }

  String _uniqueFileName(String name) {
    final dir = _downloadDir;
    if (dir == null) return name;

    var candidate = name;
    var counter = 1;
    while (File('${dir.path}/$candidate').existsSync()) {
      final dot = name.lastIndexOf('.');
      if (dot > 0) {
        candidate = '${name.substring(0, dot)} ($counter)${name.substring(dot)}';
      } else {
        candidate = '$name ($counter)';
      }
      counter++;
    }
    return candidate;
  }

  String _extractFileName(Uri uri, http.StreamedResponse response) {
    final disposition = response.headers['content-disposition'];
    if (disposition != null) {
      final match = RegExp(r'filename="?([^";\n]+)"?').firstMatch(disposition);
      if (match != null) {
        return Uri.decodeComponent(match.group(1)!.trim());
      }
    }

    final segments = uri.pathSegments;
    if (segments.isNotEmpty && segments.last.contains('.')) {
      return segments.last;
    }

    final type = response.headers['content-type']?.split(';').first.trim();
    final ext = _extensionForMime(type);
    return 'download_${DateTime.now().millisecondsSinceEpoch}$ext';
  }

  String _extensionForMime(String? mime) {
    return switch (mime) {
      'application/pdf' => '.pdf',
      'application/zip' => '.zip',
      'image/jpeg' => '.jpg',
      'image/png' => '.png',
      'video/mp4' => '.mp4',
      'audio/mpeg' => '.mp3',
      'text/plain' => '.txt',
      _ => '',
    };
  }

  Future<void> delete(DownloadItem item) async {
    final file = File(item.filePath);
    if (file.existsSync()) {
      await file.delete();
    }
    _downloads.removeWhere((d) => d.id == item.id);
    await _persist();
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_downloads.map((d) => d.toJson()).toList());
    await _prefs?.setString(_storageKey, encoded);
  }
}
