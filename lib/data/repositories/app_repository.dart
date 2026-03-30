import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';

abstract interface class AppRepository {
  AppState loadInitialState();

  Future<AppState?> loadLatestState({
    String? loginId,
  });

  Future<AuthUser> login({
    required String loginId,
    required String password,
  });

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

  Future<void> updateAlertSettings({
    required String loginId,
    required AlertSettings settings,
  });

  Future<void> saveSafeZone({
    required String loginId,
    required SafeZone zone,
  });

  Future<void> updateReward({
    required String loginId,
    required String itemId,
    required int reward,
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
}
