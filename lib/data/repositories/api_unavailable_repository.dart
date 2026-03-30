import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/repositories/app_repository.dart';

/// API 주소가 없을 때는 빈 상태만 제공하고 네트워크 기능은 사용 불가로 처리한다.
class ApiUnavailableRepository implements AppRepository {
  const ApiUnavailableRepository();

  @override
  AppState loadInitialState() => AppState.empty();

  @override
  Future<AppState?> loadLatestState({String? loginId}) async => null;

  @override
  Future<AuthUser> login({
    required String loginId,
    required String password,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 로그인할 수 없습니다.');
  }

  @override
  Future<AuthUser> register({
    required String userName,
    required String email,
    required String password,
    String? loginId,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 회원가입할 수 없습니다.');
  }

  @override
  Future<AuthUser> updateProfile({
    required String loginId,
    required String userName,
    required String email,
    required String publicName,
    String? photoAssetPath,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 프로필을 저장할 수 없습니다.');
  }

  @override
  Future<void> updateAlertSettings({
    required String loginId,
    required AlertSettings settings,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 설정을 저장할 수 없습니다.');
  }

  @override
  Future<void> saveSafeZone({
    required String loginId,
    required SafeZone zone,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 안전지대를 저장할 수 없습니다.');
  }

  @override
  Future<void> updateReward({
    required String loginId,
    required String itemId,
    required int reward,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 사례금을 저장할 수 없습니다.');
  }

  @override
  Future<String> openOrCreateChat({
    required String loginId,
    required String itemId,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 채팅방을 열 수 없습니다.');
  }

  @override
  Future<void> markChatThreadRead({
    required String loginId,
    required String threadId,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 채팅 읽음 처리를 저장할 수 없습니다.');
  }

  @override
  Future<void> sendMessage({
    required String loginId,
    required String threadId,
    required String text,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 메시지를 보낼 수 없습니다.');
  }

  @override
  Future<void> requestPhotoApproval({
    required String loginId,
    required String threadId,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 사진 요청을 저장할 수 없습니다.');
  }

  @override
  Future<void> approvePhoto({
    required String loginId,
    required String threadId,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 사진 승인을 저장할 수 없습니다.');
  }

  @override
  Future<void> submitReport({
    required String loginId,
    required String threadId,
    required String reason,
  }) {
    throw Exception('APP_API_BASE_URL이 설정되지 않아 신고를 저장할 수 없습니다.');
  }
}
