import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<bool> login(String username, String password) async {
    try {
      final token = await ApiService.login(username, password);
      _token = token;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Login failed: $e");
      return false;
    }
  }

  Future<bool> register(String username, String password) async {
    try {
      final success = await ApiService.register(username, password);
      return success;
    } catch (e) {
      debugPrint("Register failed: $e");
      return false;
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
