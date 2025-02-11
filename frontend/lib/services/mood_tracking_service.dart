/*
 File: mood_tracking_service.dart
 Purpose: Service to handle API calls for mood tracking
 Created Date: CCS-48 11-02-2025
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-49 Mood tracking 
*/

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mood_model.dart';

class MoodTrackingService {
  final String baseUrl = 'http://localhost:3000';

  Future<MoodModel> createMood(MoodModel mood) async {
    final response = await http.post(
      Uri.parse('$baseUrl/moods/create/${mood.userId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(mood.toJson()),
    );

    if (response.statusCode == 201) {
      return MoodModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create mood');
    }
  }

  Future<List<MoodModel>> getAllMoods(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/moods/getAll/$userId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> moods = json.decode(response.body);
      return moods.map((mood) => MoodModel.fromJson(mood)).toList();
    } else {
      throw Exception('Failed to load moods');
    }
  }

  Future<void> deleteMood(String userId, String moodId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/moods/delete/$userId/$moodId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete mood');
    }
  }
}