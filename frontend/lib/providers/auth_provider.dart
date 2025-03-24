/*
 File: auth_provider.dart
 Purpose: State management for user authentication.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 22/03/2024 | Dinith | CCS-55 Store JWT token
*/

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  String? _token; 
  bool get isLoggedIn => _username != null;
  String get username => _username ?? '';
  User? _user;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  static const _userKey = 'user_data';
  static const _tokenKey = 'auth_token'; 

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;
  String? get token => _token; 

  // Login and register methods
  Future<void> login(String username, String password) async {
    _username = username;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(username, password);
      _user = result['user'];
      _token = result['token']; 
      
      if (_user != null && _token != null) {
        await _saveUser(_user!);
        await _saveToken(_token!); 
      }
      notifyListeners();
    } catch (e) {
      _user = null;
      _token = null;
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
      final result = await _authService.register(
        email: email,
        password: password,
        username: username,
      );
      
      _user = result['user'];
      _token = result['token'];
      
      if (_user != null) {
        await _saveUser(_user!);
      }
      
      if (_token != null) {
        await _saveToken(_token!);
      }
      
      notifyListeners();
    } catch (e) {
      _user = null;
      _token = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  Future<void> logout() async {
    await _clearUser();
    await _clearToken(); 
    _username = null;
    _user = null;
    _token = null;
    notifyListeners();
  }

  // Sign out method
  Future<void> signOut() async {
    await logout();
  }

  // Load user method
  Future<void> loadUser() async {
    _user = await _getUser();
    _token = await _getToken(); 
    notifyListeners();
  }

  // googleSignIn method
  Future<void> googleSignIn() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.googleSignIn();
      _user = result['user'];
      _token = result['token'];
      
      if (_user != null) {
        await _saveUser(_user!);
      }
      
      if (_token != null) {
        await _saveToken(_token!);
      }
    } catch (e) {
      _user = null;
      _token = null;
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
    print(user.birthday);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> _clearUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<void> _clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<User?> _getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      try {
        final user = User.fromJson(jsonDecode(userData));
        print(user.birthday);
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

  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }
}
