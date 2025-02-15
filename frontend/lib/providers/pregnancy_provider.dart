import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class PregnancyProvider with ChangeNotifier {
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

  Future<Map<String, dynamic>> createPregnancy(String userId, DateTime lastPeriodDate) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/pregnancy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'lastPeriodDate': lastPeriodDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        notifyListeners();
        return data;
      } else {
        throw 'Failed to create pregnancy data: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }
}