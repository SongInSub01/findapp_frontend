import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';

abstract interface class AppRepository {
  AppState loadInitialState();

  Future<AppState?> loadLatestState({String? loginId});

  Future<AuthUser> login({required String loginId, required String password});

  Future<AuthUser> register({
    required String userName,
    required String email,
    required String password,
    String? loginId,
  });

  Future<AuthUser> updateProfile({
    required String loginId,
    required String userName,
    required String email,
    required String publicName,
    String? photoAssetPath,
  });

  Future<CurrentLocation> upsertCurrentLocation({
    required String loginId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  });

  Future<void> updateAlertSettings({
    required String loginId,
    required AlertSettings settings,
  });

  Future<void> saveSafeZone({required String loginId, required SafeZone zone});

  Future<void> saveBleDevice({
    required String loginId,
    required BleDevice device,
    required bool isNew,
  });

  Future<void> deleteBleDevice({
    required String loginId,
    required String deviceId,
  });

  Future<void> createLostItem({
    required String loginId,
    required String title,
    required String location,
    required int reward,
    required String description,
    DateTime? happenedAt,
    String? photoAssetPath,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
  });

  Future<void> updateLostItem({
    required String loginId,
    required String itemId,
    required String title,
    required String location,
    required int reward,
    required String description,
    DateTime? happenedAt,
    String? photoAssetPath,
    String listingStatus = 'open',
  });

  Future<void> deleteLostItem({
    required String loginId,
    required String itemId,
  });

  Future<void> createFoundItem({
    required String loginId,
    required String title,
    required String location,
    required String description,
    String? photoAssetPath,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
  });

  Future<List<ListingSummary>> searchListings({
    required String loginId,
    required String query,
    ListingType? itemType,
  });

  Future<List<MatchRecord>> loadMatches({required String loginId});

  Future<void> submitInquiry({
    required String loginId,
    required InquiryCategory category,
    required String title,
    required String body,
    ListingType? relatedItemType,
    String? relatedItemId,
  });

  Future<void> updateReward({
    required String loginId,
    required String itemId,
    required int reward,
  });

  Future<RewardStatus> loadRewardStatus({required String loginId});

  Future<RewardStatus> claimRewardQuest({
    required String loginId,
    required String questCode,
  });

  Future<RewardStatus> purchaseRewardShopItem({
    required String loginId,
    required String itemId,
  });

  Future<void> refreshBleSignal({
    required String loginId,
    required String deviceId,
    int? rssi,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    int? batteryPercent,
  });

  Future<String> openOrCreateChat({
    required String loginId,
    required String itemId,
  });

  Future<void> markChatThreadRead({
    required String loginId,
    required String threadId,
  });

  Future<void> sendMessage({
    required String loginId,
    required String threadId,
    required String text,
  });

  Future<void> requestPhotoApproval({
    required String loginId,
    required String threadId,
  });

  Future<void> approvePhoto({
    required String loginId,
    required String threadId,
  });

  Future<void> submitReport({
    required String loginId,
    required String threadId,
    required String reason,
  });

  Future<void> deleteNotification({
    required String loginId,
    required String notificationId,
  });

  Future<void> clearAllNotifications({required String loginId});
}
