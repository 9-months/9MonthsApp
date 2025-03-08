import 'package:flutter/material.dart';
import '../services/pregnancy_service.dart';

class PregnancyProvider with ChangeNotifier {
  final PregnancyService _pregnancyService = PregnancyService();

  int? _currentWeek;

  int? get currentWeek => _currentWeek;

  DateTime calculateDueDate(DateTime inputDate, bool isUltrasound) {
    if (isUltrasound) {
      return inputDate;
    }
    // If LMP date, add 280 days (40 weeks) to get due date
    return inputDate.add(const Duration(days: 280));
  }

  int calculateCurrentWeek(DateTime dueDate) {
    final today = DateTime.now();
    final difference = dueDate.difference(today);
    final remainingWeeks = (difference.inDays / 7).ceil();
    _currentWeek = 40 - remainingWeeks;
    return _currentWeek!;
  }

  Future<Map<String, dynamic>?> fetchPregnancyData(String userId) async {
    try {
      final data = await _pregnancyService.fetchPregnancyData(userId);

      // If babySize is null, set a default value
      if (data != null && data['babySize'] == null) {
        data['babySize'] = 'Not available';
      }

      return data;
    } catch (e) {
      print('Error fetching pregnancy data: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> createPregnancy(
      String userId, DateTime inputDate, bool isUltrasound) async {
    try {
      print(
          'Provider creating pregnancy - userId: $userId, inputDate: $inputDate, isUltrasound: $isUltrasound');
      final dueDate = calculateDueDate(inputDate, isUltrasound);
      print('Calculated due date: $dueDate');

      final data = await _pregnancyService.createPregnancy(userId, dueDate);
      notifyListeners();
      return data;
    } catch (e) {
      print('Provider Error: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> updatePregnancy(
      String userId, DateTime newDueDate) async {
    try {
      final data = await _pregnancyService.updatePregnancy(userId, newDueDate);
      notifyListeners();
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deletePregnancy(String userId) async {
    try {
      await _pregnancyService.deletePregnancy(userId);
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }
}
