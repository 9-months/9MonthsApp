class Pregnancy{
  final String userId;
  final DateTime lastPeriodDate;
  final DateTime dueDate;
  int currentWeek;
  String babySize;
  List<String> weeklyTips;
  DateTime updateAt;

  Pregnancy({
    required this.userId,
    required this.lastPeriodDate,
    required this.dueDate,
    required this.currentWeek,
    required this.babySize,
    required this.weeklyTips,
    required this.updateAt,
  });

  factory Pregnancy.fromJson(Map<String, dynamic> json) {
    return Pregnancy(
      userId: json['userId'],
      lastPeriodDate: DateTime.parse(json['lastPeriodDate']),
      dueDate: DateTime.parse(json['dueDate']),
      currentWeek: json['currentWeek'],
      babySize: json['babySize'],
      weeklyTips: List<String>.from(json['weeklyTips']),
      updateAt: DateTime.parse(json['updateAt']),
    );
  }
}