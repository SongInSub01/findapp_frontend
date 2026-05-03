abstract final class AppConfig {
  /// 백엔드 주소는 실행 환경에서만 주입받는다.
  static const apiBaseUrl = String.fromEnvironment('APP_API_BASE_URL');

  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;
}
