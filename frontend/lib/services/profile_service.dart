import 'package:_9months/config/config.dart';
import 'package:_9months/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfileService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  
  // Get token from secure storage
  static Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<User> completeProfile(String uid, Map<String, dynamic> profileData) async {
    final token = await _getToken();
    final url = Uri.parse('${Config.apiBaseUrl}/auth/complete-profile');
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    final response = await http.patch(
      url,
      headers: headers,
      body: json.encode({'uid': uid, 'profileData': profileData}),
    );

    if (response.statusCode != 200) {
      if (kDebugMode) {
        print('Failed to complete profile: ${response.statusCode}');
      }
      throw Exception('Failed to complete profile');
    }
    
    // Parse the response and return the updated user
    final responseData = json.decode(response.body);
    if (responseData['status'] == true && responseData['user'] != null) {
      User newUser = User.fromJson(responseData['user']);
      return newUser;
    } else {
      if (kDebugMode) {
        print('Invalid response format from server');
      }
      throw Exception('Invalid response format from server');
    }
  }
}
