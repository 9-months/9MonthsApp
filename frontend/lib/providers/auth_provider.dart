/*
 File: auth_provider.dart
 Purpose: State management for user authentication.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 12/02/2021 | Melissa | CCS-55 provider functionality updated
*/

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  static const _userKey = 'user_data';

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Login method
  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final loginUser = await _authService.login(username, password);
      if (loginUser != null) {
        _user = loginUser;
        await _saveUser(loginUser); // Save user data in background
      }
    } catch (e) {
      _user = null;
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register method
  Future<void> register({
    required String email,
    required String password,
    required String username,
    String? location,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user from registration
      final newUser = await _authService.register(
        email: email,
        password: password,
        username: username,
        location: location,
        phone: phone,
      );

      if (newUser != null) {
        // Directly set the user
        _user = newUser;
        // Save in background
        _saveUser(newUser);
      }
    } catch (e) {
      _user = null;
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    await _clearUser(); // Clear user data
    _user = null;
    notifyListeners();
  }

  // Load user method
  Future<void> loadUser() async {
    final storedUser = await _getUser();
    if (storedUser != null) {
      _user = storedUser;
      notifyListeners();
    }
  }

  // Google Sign-In method
  Future<void> googleSignIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      final googleUser = await _authService.googleSignIn();
      if (googleUser != null) {
        _user = googleUser;
        await _saveUser(googleUser); // Save in background
      }
    } catch (e) {
      _user = null;
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Storage methods
  Future<void> _saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> _clearUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<User?> _getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }
}
