class DiaryEntry {
  final String? diaryId; // Changed back to diaryId
  final String userId;
  final String description;
  final DateTime date;

  DiaryEntry({
    this.diaryId, // Changed back to diaryId
    required this.userId,
    required this.description,
    required this.date,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        diaryId: json['diaryId'] as String?, // Changed back to diaryId
        userId: json['userId'] as String,
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'description': description,
      };
}
