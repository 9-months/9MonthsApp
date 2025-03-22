

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:_9months/models/user_model.dart' as user;
import 'dart:convert';
import '../config/config.dart';

class AuthService {
  final secureStorage = FlutterSecureStorage();

  // Login method
  Future<user.User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        secureStorage.write(key: 'authToken', value: data['token']);
        return user.User.fromJson(data['user']);
      } else {
        throw Exception(
            json.decode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e, s) {
      print('Login failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Registration method
  Future<user.User> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> userData = data['user'] ?? data;
        return user.User.fromJson(userData);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e, s) {
      print('Registration failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Get single user by id
  Future<user.User> getUserById(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/auth/user/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return user.User.fromJson(data); // Return user profile data as a User object
      } else {
        throw Exception('Failed to get profile data');
      }
    } catch (e, s) {
      print('getUserById failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Failed to get profile data: ${e.toString()}');
    }
  }

  // Update user details
  Future<user.User> updateProfile(
    String uid, {
    String? email,
    String? username,
    String? location,
    String? phone,
    String? dateOfBirth,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${Config.apiBaseUrl}/auth/users/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'location': location,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
          'username': username,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return user.User.fromJson(data); // Return updated user data
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e, s) {
      print('UpdateProfile failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Delete user by id
  Future<void> deleteUser(String uid) async {
    try {
      final response = await http.delete(
        Uri.parse('${Config.apiBaseUrl}/auth/user/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e, s) {
      print('DeleteUser failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/logout'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, s) {
      print('Logout failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
