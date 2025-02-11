import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;

  Future<void> login(String username, String password) async {
    _user = await _authService.login(username, password);
    await _authService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    await _authService.logout();
    notifyListeners();
  }

  Future<void> loadUser() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }
}
