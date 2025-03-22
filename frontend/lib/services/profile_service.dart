import 'package:_9months/config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  static Future<void> completeProfile(String uid, Map<String, dynamic> profileData) async {
    final url = Uri.parse('${Config.apiBaseUrl}/auth/complete-profile');
    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uid': uid, 'profileData': profileData}),
    );

    if (response.statusCode != 200) {
      print('Failed to complete profile: ${response.body}');
      throw Exception('Failed to complete profile');
    }
  }
}
