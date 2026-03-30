/// 로그인과 회원가입 요청/응답에 사용하는 인증 모델이다.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.userName,
    required this.email,
    required this.loginId,
    required this.publicName,
  });

  final String id;
  final String userName;
  final String email;
  final String loginId;
  final String publicName;
}
