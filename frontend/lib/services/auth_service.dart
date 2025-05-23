import 'package:http/http.dart' as http;
import 'package:_9months/models/user_model.dart' as user;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import '../config/config.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
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
        final token = data['token']; // Extract the JWT token
        final userData = user.User.fromJson(data['user']);
        
        // Return both token and user
        return {
          'user': userData,
          'token': token,
        };
      } else {
        throw Exception(
            json.decode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e, s) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Registration method
  Future<Map<String, dynamic>> register({
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
        final token = data['token']; // Extract the JWT token
        final userData = user.User.fromJson(data['user'] ?? data);
        
        // Return both user and token
        return {
          'user': userData,
          'token': token,
        };
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

  // Google Sign-In method
  Future<Map<String, dynamic>> googleSignIn({Map<String, dynamic>? extraData}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('Failed to get ID Token');

      // Prepare payload with idToken and any extra registration data
      final Map<String, dynamic> payload = {'idToken': idToken};
      if (extraData != null) {
        payload.addAll(extraData);
      }

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      // Log the response for debugging
      print('Google sign-in response status: ${response.statusCode}');
      print('Google sign-in response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = user.User.fromJson(data['user']);
        final token = data['token']; // Extract the JWT token
        
        // Return both user and token
        return {
          'user': userData,
          'token': token,
        };
      } else {
        // Attempt to extract error message if possible, else fallback
        dynamic responseData;
        try {
          responseData = json.decode(response.body);
        } catch (_) {
          responseData = response.body;
        }
        throw Exception(
            responseData is Map && responseData['message'] != null 
              ? responseData['message'] 
              : 'Google sign-in failed');
      }
    } catch (e, s) {
      print('Google sign-in failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  // Get single user by id
  Future<user.User> getUserById(String uid, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/auth/user/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token to the request header
        },
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

  // Get current user data from server
  Future<user.User> getCurrentUser(String token) async {
    try {
      // Check if token is empty
      if (token.isEmpty) {
        throw Exception('No authentication token available');
      }
      
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/auth/current-user'), // Corrected endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Log response for debugging
      print('getCurrentUser response status: ${response.statusCode}');
      print('getCurrentUser response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Handle different response formats
        final userData = data['user'] ?? data;
        return user.User.fromJson(userData);
      } else {
        throw Exception('Failed to get current user data: ${response.statusCode}');
      }
    } catch (e) {
      print('GetCurrentUser failed: $e');
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user details
  Future<user.User> updateProfile(
    String uid, {
    String? email,
    String? username,
    String? location,
    String? phone,
    String? birthday,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${Config.apiBaseUrl}/auth/users/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'location': location,
          'phone': phone,
          'birthday': birthday,
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
      await _googleSignIn.signOut();
    } catch (e, s) {
      print('Logout failed with error: $e');
      print('Stack trace: $s');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
