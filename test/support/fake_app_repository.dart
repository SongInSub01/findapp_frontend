import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/repositories/app_repository.dart';

class FakeAppRepository implements AppRepository {
  @override
  AppState loadInitialState() => AppState.empty();

  @override
  Future<AppState?> loadLatestState({String? loginId}) async {
    if (loginId == null || loginId.isEmpty) {
      return AppState.empty();
    }

    return AppState(
      currentTab: AppTab.main,
      selectedMapTargetId: null,
      userProfile: UserProfile(
        id: 'u1',
        name: '테스트유저',
        email: 'tester@example.com',
        loginId: loginId,
        initials: '테',
        photoAssetPath: 'assets/images/icon.png',
        publicName: '테**',
      ),
      myDevices: const [],
      lostItems: const [],
      chatThreads: const [],
      safeZones: const [],
      alertSettings: const AlertSettings(
        distanceMeters: 10,
        disconnectMinutes: 5,
        vibrationEnabled: true,
        soundEnabled: true,
        autoApprovePhotos: false,
        keepPhotoPrivateByDefault: true,
      ),
      notifications: const [],
      reports: const [],
    );
  }

  @override
  Future<AuthUser> login({
    required String loginId,
    required String password,
  }) async {
    if (loginId != 'tester@example.com' || password != 'password123') {
      throw Exception('아이디 또는 비밀번호가 올바르지 않습니다.');
    }

    return const AuthUser(
      id: 'u1',
      userName: '테스트유저',
      email: 'tester@example.com',
      loginId: 'tester@example.com',
      publicName: '테**',
    );
  }

  @override
  Future<AuthUser> register({
    required String userName,
    required String email,
    required String password,
    String? loginId,
  }) async {
    return AuthUser(
      id: 'u1',
      userName: userName,
      email: email,
      loginId: loginId ?? email,
      publicName: userName.isEmpty ? '사**' : '${userName.substring(0, 1)}**',
    );
  }

  @override
  Future<AuthUser> updateProfile({
    required String loginId,
    required String userName,
    required String email,
    required String publicName,
    String? photoAssetPath,
  }) async {
    return AuthUser(
      id: 'u1',
      userName: userName,
      email: email,
      loginId: email,
      publicName: publicName,
    );
  }

  @override
  Future<void> updateAlertSettings({
    required String loginId,
    required AlertSettings settings,
  }) async {}

  @override
  Future<void> saveSafeZone({
    required String loginId,
    required SafeZone zone,
  }) async {}

  @override
  Future<void> updateReward({
    required String loginId,
    required String itemId,
    required int reward,
  }) async {}

  @override
  Future<String> openOrCreateChat({
    required String loginId,
    required String itemId,
  }) async {
    return 'thread-$itemId';
  }

  @override
  Future<void> markChatThreadRead({
    required String loginId,
    required String threadId,
  }) async {}

  @override
  Future<void> sendMessage({
    required String loginId,
    required String threadId,
    required String text,
  }) async {}

  @override
  Future<void> requestPhotoApproval({
    required String loginId,
    required String threadId,
  }) async {}

  @override
  Future<void> approvePhoto({
    required String loginId,
    required String threadId,
  }) async {}

  @override
  Future<void> submitReport({
    required String loginId,
    required String threadId,
    required String reason,
  }) async {}
}
