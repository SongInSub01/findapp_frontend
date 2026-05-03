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

    final isEmailLogin = loginId.contains('@');
    final userName = isEmailLogin ? '테스트유저' : loginId;
    final email = isEmailLogin ? loginId : '$loginId@example.com';
    final loginName = loginId;
    final initials = userName.isNotEmpty ? userName.substring(0, 1) : '테';
    final publicName = userName.isNotEmpty
        ? '${userName.substring(0, 1)}**'
        : '테**';

    return AppState(
      currentTab: AppTab.main,
      selectedMapTargetId: null,
      currentLocation: null,
      userProfile: UserProfile(
        id: 'u1',
        name: userName,
        email: email,
        loginId: loginName,
        initials: initials,
        photoAssetPath: 'assets/images/icon.png',
        publicName: publicName,
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
        defaultReward: 30000,
        mapTheme: MapThemeMode.light,
      ),
      notifications: const [],
      reports: const [],
      dashboardSummary: DashboardSummary.empty(),
      myLostListings: const [],
      myFoundListings: const [],
      recentLostListings: const [],
      recentFoundListings: const [],
      suggestedMatches: const [],
      inquiries: const [],
      availableCategories: const [],
      availableColors: const [],
      searchResults: const [],
    );
  }

  @override
  Future<AuthUser> login({
    required String loginId,
    required String password,
  }) async {
    if (loginId.isEmpty || password.isEmpty) {
      throw Exception('아이디 또는 비밀번호가 올바르지 않습니다.');
    }

    final isEmailLogin = loginId.contains('@');
    final userName = isEmailLogin ? '테스트유저' : loginId;
    final email = isEmailLogin ? loginId : '$loginId@example.com';

    return AuthUser(
      id: 'u-${loginId.hashCode.abs()}',
      userName: userName,
      email: email,
      loginId: loginId,
      publicName: userName.isNotEmpty ? '${userName.substring(0, 1)}**' : '테**',
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
