import 'dart:convert';
import 'package:_9months/models/pregnancy_model.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class PregnancyService {
  Future<Pregnancy> createPregnancy(String userId,DateTime lastPeriodDate) async {
    final response = await http.post(
      Uri.parse('${Config.apiBaseUrl}/pregnancy'),
      body: jsonEncode({
        'userId': userId,
        'lastPeriodDate': lastPeriodDate.toIso8601String(),
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return Pregnancy.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create pregnancy');
    }
  }
  
  Future<Pregnancy> getPregnancy(String userId) async {
    final response = await http.get(
      Uri.parse('${Config.apiBaseUrl}/pregnancy/$userId'),
    );

    if (response.statusCode == 200) {
      return Pregnancy.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Failed to load pregnancy data');
    }
  }
  
  Future<void> updatePregnancy() async {
    // Call the API to update a pregnancy
  }

  Future<void> deletePregnancy() async {
    // Call the API to delete a pregnancy
  }

  
}