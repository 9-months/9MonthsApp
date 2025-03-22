/*
 File: reminder_model.dart
 Purpose: model for reminders
 Created Date: CCS-51 14-02-2025
 Author: Dinith Perera

 last modified: 02-03-2025 | Chamod Kamiss | Updated model to match screen implementation
*/

class Reminder {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? location;
  final String dateTime;
  final String timezone;
  final String repeat;
  final List<int> alertOffsets; // Changed from single alert string
  final String type;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.location,
    required this.dateTime,
    required this.timezone,
    required this.repeat,
    required this.alertOffsets,
    required this.type,
    required this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      dateTime: json['dateTime'],
      timezone: json['timezone'],
      repeat: json['repeat'],
      alertOffsets: json['alertOffsets'] != null
          ? List<int>.from(json['alertOffsets'])
          : [0], // Default to immediate alert if none specified
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
      'dateTime': dateTime,
      'timezone': timezone,
      'repeat': repeat,
      'alertOffsets': alertOffsets,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
