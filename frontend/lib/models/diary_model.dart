class DiaryEntry {
  final String? diaryId;
  final String userId;
  final String description;
  final DateTime date;

  DiaryEntry({
    this.diaryId,
    required this.userId,
    required this.description,
    required this.date,
  });

  // Factory constructor to parse JSON data, handling nested responses from API
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final diaryData = json.containsKey('newDiaryEntry')
        ? json['newDiaryEntry']
        : (json.containsKey('updatedDiary') ? json['updatedDiary'] : json);

    return DiaryEntry(
      diaryId: diaryData['_id'] ?? diaryData['diaryId'],
      userId: diaryData['userId'],
      description: diaryData['description'],
      date: DateTime.parse(diaryData['date']),
    );
  }
// Converts the DiaryEntry instance into a JSON object for API requests
  Map<String, dynamic> toJson() => {
        'diaryId': diaryId,
        'userId': userId,
        'description': description,
        'date': date.toIso8601String(),
      };
}
