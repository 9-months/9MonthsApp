import 'package:flutter/material.dart';
import '../services/pregnancy_service.dart';

class PregnancyProvider with ChangeNotifier {
  final PregnancyService _pregnancyService = PregnancyService();

  DateTime calculateDueDate(DateTime inputDate, bool isUltrasound) {
    if (isUltrasound) {
      return inputDate;
    }
    // If LMP date, add 280 days (40 weeks) to get due date
    return inputDate.add(const Duration(days: 280));
  }

  Future<Map<String, dynamic>?> fetchPregnancyData(String userId) async {
    try {
      return await _pregnancyService.fetchPregnancyData(userId);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> createPregnancy(
      String userId, DateTime inputDate, bool isUltrasound) async {
    try {
      final dueDate =
          isUltrasound ? inputDate : inputDate.add(const Duration(days: 280));

      final data = await _pregnancyService.createPregnancy(userId, dueDate);
      notifyListeners();
      return data;
    } catch (e) {
      throw e.toString();
    }
  }
}
