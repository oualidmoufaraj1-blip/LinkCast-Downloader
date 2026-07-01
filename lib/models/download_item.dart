class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.sourceUrl,
    required this.downloadedAt,
    required this.fileSizeBytes,
    this.mimeType,
  });

  final String id;
  final String fileName;
  final String filePath;
  final String sourceUrl;
  final DateTime downloadedAt;
  final int fileSizeBytes;
  final String? mimeType;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'sourceUrl': sourceUrl,
        'downloadedAt': downloadedAt.toIso8601String(),
        'fileSizeBytes': fileSizeBytes,
        'mimeType': mimeType,
      };

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        filePath: json['filePath'] as String,
        sourceUrl: json['sourceUrl'] as String,
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
        fileSizeBytes: json['fileSizeBytes'] as int,
        mimeType: json['mimeType'] as String?,
      );
}
