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
  
  User? _partner;
  User? get partner => _partner;

  String? _partnerLinkCode;
  String? get partnerLinkCode => _partnerLinkCode;



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
    String role = 'mother',
  }) async {
    _username = username;
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        password: password,
        username: username,
        location: location,
        phone: phone,
        role: role,
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
  Future<void> loadUserData() async {
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

  //Generate partner link code
  Future<String> generatePartnerLinkCode() async {
    if (_user == null) throw Exception('User not authenticated');
    _partnerLinkCode = await _authService.generatePartnerLinkCode(_user!.uid);
    notifyListeners();
    return _partnerLinkCode!;
  }
  // Link with partner
  Future<bool> linkPartner(String partnerId) async {
    if (_user == null) return false;
    
    try {
      final success = await _authService.linkPartner(_user!.uid, partnerId);
      if (success) {
        await loadPartnerData();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
  
  // // Load partner data
  Future<void> loadPartnerData() async {
    if (_user == null || _user!.partnerId == null) {
      _partner = null;
      notifyListeners();
      return;
    }
    
    try {
      _partner = await _authService.getPartnerData(_user!.uid);
      notifyListeners();
    } catch (e) {
      _partner = null;
      notifyListeners();
    }
  }

  Future<void> loadUser() async {
    _user = await _getUser();
    if (_user != null) {
      await loadPartnerData();
    }
    notifyListeners();
  }
}
