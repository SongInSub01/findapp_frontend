import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_starter/data/repositories/api_app_repository.dart';

const _liveApiBaseUrl = String.fromEnvironment('LIVE_API_BASE_URL');

void main() {
  test(
    '실제 API 회원가입 후 이름이 부트스트랩 상태에 반영된다',
    () async {
      final repository = ApiAppRepository(baseUrl: _liveApiBaseUrl);
      final suffix = DateTime.now().millisecondsSinceEpoch;
      final email = 'live_$suffix@example.com';
      final userName = '실사용자$suffix';
      const password = 'password123';

      final registeredUser = await repository.register(
        userName: userName,
        email: email,
        password: password,
      );
      expect(registeredUser.loginId, email);

      final loggedInUser = await repository.login(
        loginId: email,
        password: password,
      );
      expect(loggedInUser.userName, userName);

      final latestState = await repository.loadLatestState(loginId: email);
      expect(latestState, isNotNull);
      expect(latestState!.userProfile.name, userName);
      expect(latestState.userProfile.email, email);
      expect(latestState.userProfile.loginId, email);
    },
    skip: _liveApiBaseUrl.isEmpty ? 'LIVE_API_BASE_URL not provided' : false,
  );
}
