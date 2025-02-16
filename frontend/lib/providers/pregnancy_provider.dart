import 'dart:convert';
import 'package:_9months/services/pregnancy_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class PregnancyProvider with ChangeNotifier {
  final PregnancyService _pregnancyService = PregnancyService();
  Future<Map<String, dynamic>?> fetchPregnancyData(String userId) async {
    try {
      return await _pregnancyService.fetchPregnancyData(userId);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> createPregnancy(String userId, DateTime lastPeriodDate) async {
    try {
      final data = await _pregnancyService.createPregnancy(userId, lastPeriodDate);
      notifyListeners();
      return data;
    } catch (e) {
      throw e.toString();
    }
  }
}