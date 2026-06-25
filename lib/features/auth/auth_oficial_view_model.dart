import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthOficialViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _employeeCode;
  String? _officerName;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  String? get employeeCode => _employeeCode;
  String? get officerName => _officerName;

  AuthOficialViewModel() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('logged_in_officer_code');
      final savedName = prefs.getString('logged_in_officer_name');
      if (savedCode != null && savedName != null) {
        _employeeCode = savedCode;
        _officerName = savedName;
        _isSuccess = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String code, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Hardcoded credentials for Fuerza de Ventas officers (S9)
    if (code.trim().toUpperCase() == 'OF12345' && password == 'caja123') {
      _isSuccess = true;
      _employeeCode = 'OF12345';
      _officerName = 'Aldo Requena'; // Personal touch
      _isLoading = false;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_in_officer_code', _employeeCode!);
        await prefs.setString('logged_in_officer_name', _officerName!);
      } catch (_) {}

      return true;
    } else {
      _isLoading = false;
      _isSuccess = false;
      _errorMessage = 'Código de empleado o contraseña incorrectos.\nPruebe OF12345 / caja123';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isSuccess = false;
    _employeeCode = null;
    _officerName = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('logged_in_officer_code');
      await prefs.remove('logged_in_officer_name');
    } catch (_) {}
  }
}
