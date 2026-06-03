import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static String get apiBaseUrl {
    const dartDefineBaseUrl = String.fromEnvironment('APP_API_BASE_URL');
    if (dartDefineBaseUrl.isNotEmpty) {
      return dartDefineBaseUrl;
    }
    return dotenv.env['APP_API_BASE_URL'] ?? '';
  }

  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;
}
