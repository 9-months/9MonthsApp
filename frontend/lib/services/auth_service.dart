import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../config/config.dart';

/// Service class that handles all authentication-related operations
class AuthService {
  /// Instance of GoogleSignIn for handling Google authentication
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Authenticates a user with username and password
  ///
  /// Returns a [User] object if successful
  /// Throws an exception if authentication fails
  Future<User> login(String username, String password) async {
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
        return User.fromJson(data['user']);
      } else {
        throw Exception(
            json.decode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Registers a new user with the provided information
  ///
  /// Required parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [username]: User's chosen username
  ///
  /// Optional parameters:
  /// - [location]: User's location
  /// - [phone]: User's phone number
  ///
  /// Returns a [User] object if registration is successful
  /// Throws an exception if registration fails
  Future<User> register({
    required String email,
    required String password,
    required String username,
    String? location,
    String? phone,
  }) async {
    try {
      // Send registration request to the server
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/signup'),
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
        // Parse the response and extract user data
        final Map<String, dynamic> data = json.decode(response.body);
        // Handle both nested and direct user data structures
        final Map<String, dynamic> userData = data['user'] ?? data;
        return User.fromJson(userData);
      } else {
        // Handle registration error
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Handles Google Sign-In authentication
  ///
  /// This method:
  /// 1. Initiates Google Sign-In flow
  /// 2. Gets authentication token
  /// 3. Verifies token with our backend
  ///
  /// Returns a [User] object if successful
  /// Throws an exception if any step fails
  Future<User> googleSignIn() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('Failed to get ID Token');

      // Verify token with backend
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['user']);
      } else {
        throw Exception(
            json.decode(response.body)['message'] ?? 'Google sign-in failed');
      }
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Signs out the current user
  ///
  /// This includes signing out from Google if it was used for authentication
  Future<void> logout() async {
    await _googleSignIn.signOut();
  }
}
