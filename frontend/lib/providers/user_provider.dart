import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  UserProvider() {
    _loadUserFromStorage(); // Load user data when provider is initialized
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('user');
    if (storedUser != null) {
      _user = User.fromJson(json.decode(storedUser));
      notifyListeners();
    }
  }

  Future<void> login(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('https://localhost:3000/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user',
          json.encode(_user!.toJson())); // Store user in SharedPreferences
      notifyListeners();
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<void> fetchUser(String uid) async {
    final response = await http.get(
      Uri.parse('https://localhost:3000/auth/user/$uid'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _user = User.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'user', json.encode(_user!.toJson())); // Store in SharedPreferences
      notifyListeners();
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user'); // Clear stored data
    notifyListeners();
  }
}
