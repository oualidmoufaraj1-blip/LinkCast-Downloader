class Favorite {
  const Favorite({
    required this.id,
    required this.name,
    required this.url,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String url;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
