abstract final class KakaoMapConfig {
  /// 카카오 지도 JavaScript key는 실행 환경에서만 주입받는다.
  static const javascriptKey = String.fromEnvironment(
    'KAKAO_MAP_JAVASCRIPT_KEY',
  );

  static bool get hasJavaScriptKey => javascriptKey.isNotEmpty;
}
