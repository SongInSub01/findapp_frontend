abstract final class AppConfig {
  /// 실행 옵션이 없으면 현재 배포된 기본 백엔드 서버를 사용한다.
  static const apiBaseUrl = String.fromEnvironment(
    'APP_API_BASE_URL',
    defaultValue: 'http://158.247.209.121:3000',
  );

  static bool get hasApiBaseUrl => apiBaseUrl.isNotEmpty;
}
