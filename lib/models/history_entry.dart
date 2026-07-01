class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.url,
    required this.visitedAt,
    this.title,
  });

  final String id;
  final String url;
  final DateTime visitedAt;
  final String? title;

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'visitedAt': visitedAt.toIso8601String(),
        'title': title,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        id: json['id'] as String,
        url: json['url'] as String,
        visitedAt: DateTime.parse(json['visitedAt'] as String),
        title: json['title'] as String?,
      );
}
