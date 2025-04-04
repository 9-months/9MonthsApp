/*
 File: diary_service.dart
 Purpose: Service to handle API calls for diary entries
 Created Date: CCS-50 24-02-2025
 Author: Melissa Joanne

 last modified: 03-03-2025 | Melissa | Base URL updated
*/

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/diary_model.dart';
import '../config/config.dart';

class DiaryService {
  final String _baseUrl = '${Config.apiBaseUrl}/diary';

  Future<List<DiaryEntry>> getDiaries(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getAll/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token to header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DiaryEntry.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to load diaries: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<DiaryEntry> getDiaryById(String userId, String diaryId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get/$userId/$diaryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token to header
        },
      );

      if (response.statusCode == 200) {
        return DiaryEntry.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Diary entry not found');
      } else {
        throw Exception('Failed to load diary: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<DiaryEntry> createDiary(String userId, String description, String token) async {
    return createDiaryWithDate(userId, description, DateTime.now(), token);
  }

  Future<DiaryEntry> createDiaryWithDate(
      String userId, String description, DateTime date, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: json.encode({
          'description': description,
          'date': date.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return DiaryEntry.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('Invalid diary data provided');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to create diary: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<DiaryEntry> updateDiary(
      String userId, String diaryId, String description, String token) async {
    // Get the current diary to preserve its date if not provided
    final currentDiary = await getDiaryById(userId, diaryId, token);
    return updateDiaryWithDate(userId, diaryId, description, currentDiary.date, token);
  }

  Future<DiaryEntry> updateDiaryWithDate(
      String userId, String diaryId, String description, DateTime date, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/update/$userId/$diaryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token to header
        },
        body: json.encode({
          'description': description,
          'date': date.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return DiaryEntry.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('Invalid diary data provided');
      } else if (response.statusCode == 404) {
        throw Exception('Diary entry or user not found');
      } else {
        throw Exception('Failed to update diary: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<void> deleteDiary(String userId, String diaryId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/$userId/$diaryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token to header
        },
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Diary entry or user not found');
      } else {
        throw Exception('Failed to delete diary: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  // New method for getting diaries by date range
  Future<List<DiaryEntry>> getDiariesByDateRange(
      String userId, DateTime startDate, DateTime endDate, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/getByDateRange/$userId?start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add token to header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DiaryEntry.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to load diaries: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }
}
