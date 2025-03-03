import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/diary_model.dart';
import '../config/config.dart';

class DiaryService {
  final String _baseUrl = Config.apiBaseUrl;

  Future<List<DiaryEntry>> getDiaries(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/getAll/$userId'),
        headers: {'Content-Type': 'application/json'},
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
      throw Exception('Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<DiaryEntry> getDiaryById(String userId, String diaryId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get/$userId/$diaryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return DiaryEntry.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Diary entry not found');
      } else {
        throw Exception('Failed to load diary: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<DiaryEntry> createDiary(String userId, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': description,
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
      throw Exception('Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<DiaryEntry> updateDiary(String userId, String diaryId, String description) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/update/$userId/$diaryId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'description': description,
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
      throw Exception('Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }

  Future<void> deleteDiary(String userId, String diaryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/$userId/$diaryId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Diary entry or user not found');
      } else {
        throw Exception('Failed to delete diary: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Connection failed. Please check your internet connection.');
    } catch (e) {
      throw Exception('Something went wrong: ${e.toString()}');
    }
  }
}