import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class PregnancyService {
  Future<Map<String, dynamic>> createPregnancy(
      String userId, DateTime dueDate) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/pregnancy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'dueDate': dueDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw 'Failed to create pregnancy data: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<Map<String, dynamic>?> fetchPregnancyData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/pregnancy/$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw 'Failed to load pregnancy data: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<void> updatePregnancy() async {
    // Call the API to update a pregnancy
  }

  Future<void> deletePregnancy() async {
    // Call the API to delete a pregnancy
  }
}
