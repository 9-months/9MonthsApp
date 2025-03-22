/*
 * File: auth_provider.dart
 * Purpose: State management for user authentication.
 * Created: 11/02/2021 CCS-55 State Management
 * 
 * Last modified: Current Date | State management optimization and code cleanup
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Manages authentication state throughout the application
class AuthProvider extends ChangeNotifier {
  // Private fields
  User? _user;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  // Storage constants
  static const _userKey = 'user_data';

  // Public getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get username => _user?.username ?? '';

  /// Authenticates user with email/username and password
  /// Throws exceptions for authentication failures
  Future<void> login(String username, String password) async {
    _setLoading(true);
    
    try {
      _user = await _authService.login(username, password);
      if (_user != null) {
        await _saveUser(_user!);
      }
    } catch (e) {
      _user = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Registers a new user account
  /// Throws exceptions for registration failures
  Future<void> register({
    required String email,
    required String password,
    required String username,
    String? location,
    String? phone,
  }) async {
    _setLoading(true);
    
    try {
      _user = await _authService.register(
        email: email,
        password: password,
        username: username,
      );
      if (_user != null) {
        await _saveUser(_user!);
      }
    } catch (e) {
      _user = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user and clears stored credentials
  Future<void> logout() async {
    await _clearUser();
    _user = null;
    notifyListeners();
  }

  /// Loads user data from secure storage if available
  Future<void> loadUser() async {
    _user = await _getUser();
    notifyListeners();
  }


  /// Updates the current user's profile information
  Future<void> updateUserProfile({
    String? location,
    String? phone,
    String? dateOfBirth,
    String? accountType,
  }) async {
    if (_user == null) return;
    
    _user = _user!.copyWith(
      location: location,
      phone: phone,
      dateOfBirth: dateOfBirth,
      accountType: accountType,
    );
    
    await _saveUser(_user!);
    notifyListeners();
  }

  // Helper methods
  /// Saves user data to secure storage
  Future<void> _saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  /// Clears user data from secure storage
  Future<void> _clearUser() async {
    await _storage.delete(key: _userKey);
  }

  /// Retrieves user data from secure storage
  Future<User?> _getUser() async {
    final userData = await _storage.read(key: _userKey);
    return userData != null ? User.fromJson(jsonDecode(userData)) : null;
  }
  
  /// Updates loading state and notifies listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
