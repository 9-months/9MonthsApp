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
}