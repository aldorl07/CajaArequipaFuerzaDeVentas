import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthOficialViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _employeeCode;
  String? _officerName;
  String _userRole = 'operador';
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  String? get employeeCode => _employeeCode;
  String? get officerName => _officerName;
  String get userRole => _userRole;
  int get failedAttempts => _failedAttempts;
  DateTime? get lockoutUntil => _lockoutUntil;

  bool get isLockedOut {
    if (_lockoutUntil == null) return false;
    if (DateTime.now().isAfter(_lockoutUntil!)) {
      _lockoutUntil = null;
      _failedAttempts = 0;
      _saveLockoutState();
      return false;
    }
    return true;
  }

  int get lockoutSecondsRemaining {
    if (_lockoutUntil == null) return 0;
    final diff = _lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  AuthOficialViewModel() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _loadLockoutState();
      
      final savedCode = prefs.getString('logged_in_officer_code');
      final savedName = prefs.getString('logged_in_officer_name');
      final savedRole = prefs.getString('logged_in_officer_role');
      
      if (savedCode != null && savedName != null) {
        _employeeCode = savedCode;
        _officerName = savedName;
        if (savedRole != null) {
          _userRole = savedRole;
        }
        _isSuccess = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _loadLockoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _failedAttempts = prefs.getInt('login_failed_attempts') ?? 0;
      final lockoutMillis = prefs.getInt('login_lockout_until');
      if (lockoutMillis != null) {
        _lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutMillis);
      }
    } catch (_) {}
  }

  Future<void> _saveLockoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('login_failed_attempts', _failedAttempts);
      if (_lockoutUntil != null) {
        await prefs.setInt('login_lockout_until', _lockoutUntil!.millisecondsSinceEpoch);
      } else {
        await prefs.remove('login_lockout_until');
      }
    } catch (_) {}
  }

  Future<bool> login(String code, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    // Check lockout first
    if (isLockedOut) {
      _isLoading = false;
      _errorMessage = 'Acceso bloqueado temporalmente. Cuenta regresiva activa.';
      notifyListeners();
      return false;
    }

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Hardcoded credentials for Fuerza de Ventas officers (S9)
    if (code.trim().toUpperCase() == 'OF12345' && password == 'caja123') {
      _isSuccess = true;
      _employeeCode = 'OF12345';
      _officerName = 'Aldo Requena';
      _userRole = 'operador';
      _failedAttempts = 0;
      _lockoutUntil = null;
      _isLoading = false;
      
      await _saveLockoutState();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_in_officer_code', _employeeCode!);
        await prefs.setString('logged_in_officer_name', _officerName!);
        await prefs.setString('logged_in_officer_role', _userRole);
      } catch (_) {}

      notifyListeners();
      return true;
    } else {
      _failedAttempts++;
      _isSuccess = false;
      _isLoading = false;
      
      if (_failedAttempts >= 5) {
        _lockoutUntil = DateTime.now().add(const Duration(minutes: 30));
        _errorMessage = 'Superó los 5 intentos fallidos. Acceso bloqueado por 30 minutos.';
      } else {
        _errorMessage = 'Código de empleado o contraseña incorrectos.\nIntentos restantes: ${5 - _failedAttempts}\nPruebe OF12345 / caja123';
      }
      
      await _saveLockoutState();
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
      await prefs.remove('logged_in_officer_role');
      // Do not clear lockout state here, to prevent bypassing lockout by deleting session.
    } catch (_) {}
  }
}
