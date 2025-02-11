// lib/providers/user_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  Future<void> login(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse(
          'https://api.example.com/login'), // Replace with your login endpoint
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
      notifyListeners();
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<void> fetchUser(String uid) async {
    final response = await http.get(
      Uri.parse(
          'https://api.example.com/user/$uid'), // Replace with your user endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token', // Include token if needed
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _user = User.fromJson(data);
      notifyListeners();
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    notifyListeners();
  }
}
