/*
 File: mood_tracking_service.dart
 Purpose: Service to handle API calls for mood tracking
 Created Date: CCS-48 11-02-2025
 Author: Dinith Perera

 last modified: 03-03-2025 | Dinith | Base URL updated
*/

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mood_model.dart';
import '../config/config.dart';

class MoodTrackingService {
  final String baseUrl = Config.apiBaseUrl;

  // Create a new mood entry
  Future<MoodModel> createMood(MoodModel mood, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/moods/create/${mood.userId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token to authorization header
      },
      body: json.encode(mood.toJson()),
    );

    if (response.statusCode == 201) {
      return MoodModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create mood');
    }
  }

  // Get all mood entries for a user
  Future<List<MoodModel>> getAllMoods(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/moods/getAll/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token to authorization header
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> moods = json.decode(response.body);
      return moods.map((mood) => MoodModel.fromJson(mood)).toList();
    } else {
      throw Exception('Failed to load moods');
    }
  }

  // delete a mood entry
  Future<void> deleteMood(String userId, String moodId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/moods/delete/$userId/$moodId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token to authorization header
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete mood');
    }
  }

  // update a mood entry
  Future<MoodModel> updateMood(String userId, String moodId, MoodModel mood, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/moods/update/$userId/$moodId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Add token to authorization header
      },
      body: json.encode(mood.toJson()),
    );

    if (response.statusCode == 200) {
      return MoodModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update mood');
    }
  }
}