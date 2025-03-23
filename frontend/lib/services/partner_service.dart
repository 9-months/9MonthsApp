import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/user_model.dart';

class PartnerService {
  /// Links a partner using their link code
  /// 
  /// Sends a request to the backend with the current user's uid and the partner's link code
  /// Returns the partner's information if successful
  static Future<Map<String, dynamic>> linkPartner(String uid, String partnerLinkCode) async {
    try {
      final url = Uri.parse('${Config.apiBaseUrl}/auth/link-partner');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': uid,
          'partnerLinkCode': partnerLinkCode,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'partner': responseData['partner'] != null 
              ? User.fromJson(responseData['partner']) 
              : null,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to link partner',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}
