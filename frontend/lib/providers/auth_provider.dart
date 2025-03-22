/*
 File: auth_provider.dart
 Purpose: State management for user authentication.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 15/02/2024 | Chamod | CCS-55 provider functionality updated
*/

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  bool get isLoggedIn => _username != null;
  String get username => _username ?? '';
  User? _user;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  static const _userKey = 'user_data';

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Login and register methods
  Future<void> login(String username, String password) async {
    _username = username;
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(username, password);
      if (_user != null) {
        await _saveUser(_user!);
      }
      notifyListeners();
    } catch (e) {
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    String? location,
    String? phone,
  }) async {
    _username = username;
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        username: username,
      );
      if (_user != null) {
        await _saveUser(_user!);
      }
      notifyListeners();
    } catch (e) {
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    await _clearUser();
    _username = null;
    _user = null;
    notifyListeners();
  }

  // Sign out method
  Future<void> signOut() async {
    await logout();
  }

  // Load user method
  Future<void> loadUser() async {
    _user = await _getUser();
    notifyListeners();
  }

  // googleSignIn method
  Future<void> googleSignIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.googleSignIn();
      if (_user != null) {
        await _saveUser(_user!);
      }
    } catch (e) {
      _user = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile data and save to secure storage
  Future<void> updateUserProfile({
    String? location,
    String? phone,
    String? birthday,
    String? accountType,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        location: location,
        phone: phone,
        birthday: birthday,
        accountType: accountType,
      );
      await _saveUser(_user!);
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
      try {
        // For debugging
        if (kDebugMode) {
          print('Retrieved user data: $userData');
          final decoded = jsonDecode(userData);
          print('Decoded data contains birthday: ${decoded.containsKey('birthday')}');
        }
        
        final user = User.fromJson(jsonDecode(userData));
        
        // Verify the birthday was properly deserialized
        if (kDebugMode && user.birthday == null) {
          print('Warning: birthday is null after deserialization');
        }
        
        return user;
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing user data: $e');
        }
        await _clearUser(); // Clear corrupted data
        return null;
      }
    }
    return null;
  }
}
