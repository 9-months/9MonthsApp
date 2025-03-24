import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pregnancy_service.dart';
import '../providers/auth_provider.dart';
import '../main.dart';

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

      if (data != null) {
        // If babySize is null, set a default value
        if (data['babySize'] == null) {
          data['babySize'] = 'Not available';
        }

        // If currentWeek is not already set in the data, calculate it
        if (!data.containsKey('currentWeek') || data['currentWeek'] == null) {
          if (data.containsKey('dueDate') && data['dueDate'] != null) {
            final dueDate = DateTime.parse(data['dueDate']);
            data['currentWeek'] = calculateCurrentWeek(dueDate);
          }
        }
      }

      return data;
    } catch (e) {
      print('Error fetching pregnancy data: $e');
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> fetchPregnancyTips(int week) async {
    try {
      final authToken = Provider.of<AuthProvider>(
        navigatorKey.currentContext!,
        listen: false
      ).token;
      
      if (authToken == null) {
        throw 'Authentication error: Please login again';
      }
      
      final tips = await _pregnancyService.fetchTipsForWeek(week, authToken);
      return tips;
    } catch (e) {
      print('Error fetching pregnancy tips: $e');
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> fetchCurrentWeekTips(String userId) async {
    try {
      // First get the pregnancy data to know the current week
      final pregnancyData = await fetchPregnancyData(userId);

      if (pregnancyData == null || pregnancyData['currentWeek'] == null) {
        throw 'No pregnancy data or current week information available';
      }

      int week = pregnancyData['currentWeek'];
      return await fetchPregnancyTips(week);
    } catch (e) {
      print('Error fetching current week tips: $e');
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

  // Add this method to refresh data after partner linking
  Future<void> refreshAfterPartnerLinking(String userId) async {
    try {
      print('Refreshing data after partner linking: $userId');
      // Fetch fresh data after partner linking
      await fetchPregnancyData(userId);
      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print('Error refreshing after partner linking: $e');
      throw e.toString();
    }
  }
}
