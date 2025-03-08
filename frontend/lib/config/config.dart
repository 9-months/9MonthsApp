import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get apiBaseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';
}
