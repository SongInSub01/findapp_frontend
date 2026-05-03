import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/repositories/app_repository.dart';

import 'support/fake_session_store.dart';

class _BootstrapNullRepository implements AppRepository {
  @override
  AppState loadInitialState() => AppState.empty();

  @override
  Future<AppState?> loadLatestState({String? loginId}) async => null;

  @override
  Future<AuthUser> login({
    required String loginId,
    required String password,
  }) async {
    final userName = loginId.contains('@') ? '테스트유저' : loginId;
    final publicName = userName.isNotEmpty
        ? '${userName.substring(0, 1)}**'
        : '테**';
    return AuthUser(
      id: 'u-${loginId.hashCode.abs()}',
      userName: userName,
      email: loginId.contains('@') ? loginId : '$loginId@example.com',
      loginId: loginId,
      publicName: publicName,
    );
  }

  @override
  Future<AuthUser> register({
    required String userName,
    required String email,
    required String password,
    String? loginId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> updateProfile({
    required String loginId,
    required String userName,
    required String email,
    required String publicName,
    String? photoAssetPath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<CurrentLocation> upsertCurrentLocation({
    required String loginId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  }) async {
    return CurrentLocation(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      updatedAt: DateTime.now().toIso8601String(),
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
  Future<void> saveBleDevice({
    required String loginId,
    required BleDevice device,
    required bool isNew,
  }) async {}

  @override
  Future<void> createLostItem({
    required String loginId,
    required String title,
    required String location,
    required int reward,
    required String description,
    String? photoAssetPath,
  }) async {}

  @override
  Future<void> createFoundItem({
    required String loginId,
    required String title,
    required String location,
    required String description,
    String? photoAssetPath,
  }) async {}

  @override
  Future<List<ListingSummary>> searchListings({
    required String loginId,
    required String query,
    ListingType? itemType,
  }) async {
    return const [];
  }

  @override
  Future<List<MatchRecord>> loadMatches({required String loginId}) async {
    return const [];
  }

  @override
  Future<void> submitInquiry({
    required String loginId,
    required InquiryCategory category,
    required String title,
    required String body,
    ListingType? relatedItemType,
    String? relatedItemId,
  }) async {}

  @override
  Future<void> updateReward({
    required String loginId,
    required String itemId,
    required int reward,
  }) async {}

  @override
  Future<void> refreshBleSignal({
    required String loginId,
    required String deviceId,
  }) async {}

  @override
  Future<String> openOrCreateChat({
    required String loginId,
    required String itemId,
  }) async => '';

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

void main() {
  test('bootstrap 결과가 비어 있으면 저장된 세션을 지우고 로그인 상태를 해제한다', () async {
    final sessionStore = FakeSessionStore();
    await sessionStore.saveLoginId('missing-user');

    final controller = AppController(
      initialState: AppState.empty(),
      repository: _BootstrapNullRepository(),
      sessionStore: sessionStore,
      activeLoginId: 'missing-user',
    );

    await controller.bootstrap();

    expect(controller.isAuthenticated, isFalse);
    expect(controller.state.userProfile.loginId, isEmpty);
    expect(await sessionStore.readLoginId(), isNull);
  });

  test('로그인 후 bootstrap 결과가 없어도 최소 사용자 프로필은 유지한다', () async {
    final controller = AppController(
      initialState: AppState.empty(),
      repository: _BootstrapNullRepository(),
      sessionStore: FakeSessionStore(),
    );

    await controller.signIn(
      loginId: 'tester@example.com',
      password: 'password123',
      rememberMe: true,
    );

    expect(controller.isAuthenticated, isTrue);
    expect(controller.state.userProfile.loginId, 'tester@example.com');
    expect(controller.state.userProfile.name, '테스트유저');
    expect(controller.state.userProfile.publicName, '테**');
  });
}
