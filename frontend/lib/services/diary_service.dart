import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/diary_model.dart';

class DiaryService {
  final String _baseUrl = 'http://localhost:3000/diary';

  Future<List<DiaryEntry>> getDiaries(String userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DiaryEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load diaries');
      }
    } catch (e) {
      throw _handleHttpError(e);
    }
  }

  Future<DiaryEntry> createDiary(String userId, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'description': description}),
      );
      if (response.statusCode == 201) {
        return DiaryEntry.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create diary');
      }
    } catch (e) {
      throw _handleHttpError(e);
    }
  }

  Future<DiaryEntry> updateDiary(
      String userId, String diaryId, String description) async {
    // Changed back to diaryId
    try {
      final response = await http.put(
        Uri.parse(
            '$_baseUrl/update/$userId/$diaryId'), // Changed back to diaryId
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'description': description}),
      );
      if (response.statusCode == 200) {
        return DiaryEntry.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update diary');
      }
    } catch (e) {
      throw _handleHttpError(e);
    }
  }

  Future<void> deleteDiary(String userId, String diaryId) async {
    // Changed back to diaryId
    try {
      final response = await http.delete(Uri.parse(
          '$_baseUrl/delete/$userId/$diaryId')); // Changed back to diaryId
      if (response.statusCode != 200) {
        throw Exception('Failed to delete diary');
      }
    } catch (e) {
      throw _handleHttpError(e);
    }
  }

  String _handleHttpError(dynamic e) {
    if (e is http.ClientException) {
      return 'Connection error';
    } else {
      return 'Something went wrong';
    }
  }
}
