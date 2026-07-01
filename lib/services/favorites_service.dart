import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();

  static const _storageKey = 'favorites';
  SharedPreferences? _prefs;
  List<Favorite> _favorites = [];

  List<Favorite> get favorites => List.unmodifiable(_favorites);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _favorites = list
          .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> add(Favorite favorite) async {
    _favorites.removeWhere((f) => f.url == favorite.url);
    _favorites.insert(0, favorite);
    await _persist();
  }

  bool hasUrl(String url) => _favorites.any((f) => f.url == url);

  Favorite? findByUrl(String url) {
    for (final favorite in _favorites) {
      if (favorite.url == url) return favorite;
    }
    return null;
  }

  Future<void> remove(String id) async {
    _favorites.removeWhere((f) => f.id == id);
    await _persist();
  }

  Future<void> update(Favorite favorite) async {
    final index = _favorites.indexWhere((f) => f.id == favorite.id);
    if (index != -1) {
      _favorites[index] = favorite;
      await _persist();
    }
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_favorites.map((f) => f.toJson()).toList());
    await _prefs?.setString(_storageKey, encoded);
  }
}
