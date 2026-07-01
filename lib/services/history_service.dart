import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';

class HistoryService extends ChangeNotifier {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  static const _storageKey = 'url_history';
  static const _maxEntries = 50;

  SharedPreferences? _prefs;
  List<HistoryEntry> _entries = [];

  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_storageKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _entries = list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> add(String url, {String? title}) async {
    _entries.removeWhere((e) => e.url == url);
    _entries.insert(
      0,
      HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        url: url,
        visitedAt: DateTime.now(),
        title: title,
      ),
    );
    if (_entries.length > _maxEntries) {
      _entries = _entries.sublist(0, _maxEntries);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _entries = [];
    await _prefs?.remove(_storageKey);
    notifyListeners();
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await _prefs?.setString(_storageKey, encoded);
  }
}
