/*
 File: reminder_model.dart
 Purpose: model for reminders
 Created Date: CCS-51 14-02-2025
 Author: Dinith Perera

 last modified: 14-02-2025 | Ryan | CCS-51 Reminder tracking 
*/

class ReminderModel {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String time;
  final String repeat;
  final String alert;
  final String type;
  final DateTime createdAt;

  ReminderModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.repeat,
    required this.alert,
    required this.type,
    required this.createdAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      repeat: json['repeat'],
      alert: json['alert'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'time': time,
      'repeat': repeat,
      'alert': alert,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
