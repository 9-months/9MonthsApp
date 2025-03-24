/*
 File: reminder_service.dart
 Purpose: Service for interacting with reminder API
 Created Date: 02-03-2025
 Author: Chamod Kamiss
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/reminder_model.dart';

class ReminderService {
  final String baseUrl = Config.apiBaseUrl;

  // Create a new reminder
  Future<Reminder> createReminder(
      String userId, Map<String, dynamic> reminderData, String token) async {
    final response = await http.post(
      Uri.parse('${Config.apiBaseUrl}/reminder/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(reminderData),
    );

    if (response.statusCode == 201) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create reminder: ${response.body}');
    }
  }

  // Get all reminders for a user
  Future<List<Reminder>> getRemindersByUser(String userId, String token) async {
    final response = await http.get(
      Uri.parse('${Config.apiBaseUrl}/reminder/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> remindersJson = jsonDecode(response.body);
      return remindersJson.map((json) => Reminder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch reminders: ${response.body}');
    }
  }

  // Get a specific reminder
  Future<Reminder> getReminder(
      String userId, String reminderId, String token) async {
    final response = await http.get(
      Uri.parse(
          '${Config.apiBaseUrl}/reminder/$userId/$reminderId'), // Fixed path
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch reminder: ${response.body}');
    }
  }

  // Update an existing reminder
  Future<Reminder> updateReminder(String userId, String reminderId,
      Map<String, dynamic> reminderData, String token) async {
    final response = await http.put(
      Uri.parse(
          '${Config.apiBaseUrl}/reminder/$userId/$reminderId'), // Fixed path
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(reminderData),
    );
    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update reminder: ${response.body}');
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(
      String userId, String reminderId, String token) async {
    final response = await http.delete(
      Uri.parse(
          '${Config.apiBaseUrl}/reminder/$userId/$reminderId'), // Fixed path
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reminder: ${response.body}');
    }
  }
}
