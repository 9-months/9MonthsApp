import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyService {
  static const String baseUrl = 'http://localhost:3000';

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