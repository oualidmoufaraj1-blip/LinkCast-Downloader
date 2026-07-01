import 'package:flutter/foundation.dart';

class DownloadProgress extends ChangeNotifier {
  DownloadProgress._();
  static final DownloadProgress instance = DownloadProgress._();

  bool _active = false;
  double _progress = 0;
  String _fileName = '';

  bool get active => _active;
  double get progress => _progress;
  String get fileName => _fileName;

  void start(String fileName) {
    _active = true;
    _progress = 0;
    _fileName = fileName;
    notifyListeners();
  }

  void update(double value) {
    _progress = value.clamp(0, 1);
    notifyListeners();
  }

  void finish() {
    _active = false;
    _progress = 0;
    _fileName = '';
    notifyListeners();
  }
}
