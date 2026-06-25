import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _userName;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;

  AuthViewModel() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('logged_in_user');
      if (savedUser != null) {
        _userName = savedUser;
        _isSuccess = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));

    // Hardcoded credentials as requested by criteria of acceptance
    if (username.trim().toLowerCase() == 'admin' && password == '123456') {
      _isSuccess = true;
      _userName = 'Aldo Requena'; // Personal touch matching the user context
      _isLoading = false;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_in_user', _userName!);
      } catch (_) {}

      return true;
    } else {
      _isLoading = false;
      _isSuccess = false;
      _errorMessage = 'Credenciales incorrectas. Pruebe admin / 123456';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isSuccess = false;
    _userName = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('logged_in_user');
    } catch (_) {}
  }
}
