/*
 File: emergency_service.dart
 Purpose: Service to handle API calls for emergency service
 Created Date: CCS-50 09-02-2025
 Author: Dinith Perera

 last modified: 08-03-2025 | Dinith | Added call type logging
*/

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';

class EmergencyService {
  final String baseUrl = Config.apiBaseUrl;

  Future<void> sendEmergencyAlert() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emergency'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 'dummy-123',
          'location': 'Test Location',
          'message': 'Emergency assistance needed'
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send emergency alert');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // New method to log specific call types
  Future<void> sendEmergencyAlertWithType({
    required String callType,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emergency'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 'dummy-123',
          'location': location,
          'message': 'Emergency $callType call initiated',
          'callType': callType
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send emergency alert');
      }
    } catch (e) {
      rethrow;
    }
  }
}