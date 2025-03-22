import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class PregnancyService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  
  // Private method to get token from secure storage
  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Helper method to create auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> createPregnancy(String userId, DateTime dueDate) async {
    try {
      print('Making API call to create pregnancy with userId: $userId, dueDate: $dueDate');

      String formattedDate = dueDate.toIso8601String().split('T')[0];
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/pregnancy'),
        headers: headers,
        body: json.encode({
          'userId': userId,
          'dueDate': formattedDate,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw 'Authentication error: Please login again';
      } else {
        throw 'Failed to create pregnancy data: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      print('Pregnancy Service Error: $e');
      throw 'Network error: $e';
    }
  }

  Future<Map<String, dynamic>?> fetchPregnancyData(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/pregnancy/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw 'Authentication error: Please login again';
      } else {
        throw 'Failed to load pregnancy data: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<Map<String, dynamic>> updatePregnancy(String userId, DateTime newDueDate) async {
    try {
      String formattedDate = newDueDate.toIso8601String().split('T')[0];
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('${Config.apiBaseUrl}/pregnancy/$userId'),
        headers: headers,
        body: json.encode({
          'dueDate': formattedDate,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw 'Authentication error: Please login again';
      } else {
        throw 'Failed to update pregnancy data: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<void> deletePregnancy(String userId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse('${Config.apiBaseUrl}/pregnancy/$userId'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw 'Authentication error: Please login again';
      } else if (response.statusCode != 200) {
        throw 'Failed to delete pregnancy data: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<List<Map<String, dynamic>>> fetchTipsForWeek(int week) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/tips/week/$week/tips'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> tips =
            data.map((item) => item as Map<String, dynamic>).toList();
        return tips;
      } else if (response.statusCode == 401) {
        print('Authentication error: Please login again');
        return [];
      } else {
        print('Failed to load tips data for week $week: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching tips for week $week: $e');
      return [];
    }
  }
}
