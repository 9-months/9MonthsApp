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
  Future<Reminder> createReminder(String userId, Map<String, dynamic> reminderData) async {
     final response = await http.post(
    Uri.parse('$baseUrl/reminder/$userId'),
    headers: {
      'Content-Type': 'application/json',
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
  Future<List<Reminder>> getRemindersByUser(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reminder/$userId'),
      headers: {
        // Add authorization header here if needed
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> remindersJson = jsonDecode(response.body);
      return remindersJson.map((json) => Reminder.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch reminders: ${response.body}');
    }
  }

  // Get a specific reminder
  Future<Reminder> getReminder(String userId, String reminderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reminder/$userId/$reminderId'), // Fixed path
      headers: {
        // Add authorization header here if needed
      },
    );

    if (response.statusCode == 200) {
      return Reminder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch reminder: ${response.body}');
    }
  }

  // Update an existing reminder
  Future<Reminder> updateReminder(String userId, String reminderId, Map<String, dynamic> reminderData) async {
     final response = await http.put(
    Uri.parse('$baseUrl/reminder/$userId/$reminderId'), // Fixed path
    headers: {
      'Content-Type': 'application/json',
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
  Future<void> deleteReminder(String userId, String reminderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/reminder/$userId/$reminderId'), // Fixed path
      headers: {
        // Add authorization header here if needed
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete reminder: ${response.body}');
    }
  }
}