/*
 File: auth_service.dart
 Purpose: handle user authentication
 Created Date: 11-02-2025 CCS-55 State Management
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | Creare service 
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class AuthService {
  final String baseUrl = Config.apiBaseUrl;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    required String location,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'username': username,
        'location': location,
        'phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google-signin'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }

  Future<Map<String, dynamic>> getUser(String uid, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/user/$uid'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['message']);
    }
  }
}