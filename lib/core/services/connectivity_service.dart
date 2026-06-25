import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  final String _prefKey = 'simulated_online_status';

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnline = prefs.getBool(_prefKey) ?? true;
      notifyListeners();
    } catch (_) {
      // SharedPreferences fails on some platforms if not initialized
    }
  }

  Future<void> toggleConnection() async {
    _isOnline = !_isOnline;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, _isOnline);
    } catch (_) {}
  }

  Future<void> setOnline(bool value) async {
    if (_isOnline == value) return;
    _isOnline = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, _isOnline);
    } catch (_) {}
  }
}
