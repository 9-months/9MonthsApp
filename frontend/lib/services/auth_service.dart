/*
 File: auth_service.dart
 Purpose: Contains the authentication service class.
 Created Date: 11/02/2021 CCS-55 State Management
 Author: Dinith Perera

 last modified: 11/02/2021 | Dinith | CCS-55 authentication service created
*/

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  Future<User> login(String username, String password) async {
    // Simulate a network request
    await Future.delayed(Duration(seconds: 2));
    // Normally, you would make a network request here
    // For simplicity, we return a dummy user
    return User(id: '1', username: username, email: 'user@example.com');
  }

  Future<void> logout() async {
    // Clear user data from persistent storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<User?> getCurrentUser() async {
    // Retrieve user data from persistent storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? email = prefs.getString('email');
    if (username != null && email != null) {
      return User(id: '1', username: username, email: email);
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    // Save user data to persistent storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
  }
}
