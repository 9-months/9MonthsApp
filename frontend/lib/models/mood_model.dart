/*
 File: mood_tracking_service.dart
 Purpose: model for mood tracking
 Created Date: CCS-48 11-02-2025
 Author: Dinith Perera

 last modified: 11-02-2025 | Dinith | CCS-49 Mood tracking 
*/

class MoodModel {
  final String? id;
  final String userId;
  final String mood;
  final String note;
  final DateTime date;

  MoodModel({
    this.id,
    required this.userId,
    required this.mood,
    required this.note,
    required this.date,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['_id'],
      userId: json['userId'],
      mood: json['mood'],
      note: json['note'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'mood': mood,
      'note': note,
      'date': date.toIso8601String(),
    };
  }
}
