import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:my_flutter_starter/core/config/app_config.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/repositories/app_repository.dart';
import 'package:my_flutter_starter/data/sources/app_state_json_mapper.dart';

/// 찾아줘 백엔드 API와 직접 통신하는 실제 저장소 구현체다.
class ApiAppRepository implements AppRepository {
  ApiAppRepository({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  AppState loadInitialState() => AppState.empty();

  @override
  Future<AppState?> loadLatestState({
    String? loginId,
  }) async {
    if (_baseUrl.isEmpty || loginId == null || loginId.isEmpty) {
      return null;
    }

    final baseUri = Uri.parse(_baseUrl);
    final uri = baseUri.resolve('/api/v1/bootstrap').replace(
      queryParameters: {'loginId': loginId},
    );
    final response = await _client.get(uri);
    final payload = _decodeMap(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(payload['message'] ?? '부트스트랩 데이터를 불러오지 못했습니다.');
    }

    return AppStateJsonMapper.fromBootstrapJson(payload);
  }

  @override
  Future<AuthUser> login({
    required String loginId,
    required String password,
  }) async {
    final payload = await _postJson(
      '/api/v1/auth/login',
      body: {
        'loginId': loginId,
        'password': password,
      },
    );

    return _authUserFromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthUser> register({
    required String userName,
    required String email,
    required String password,
    String? loginId,
  }) async {
    final payload = await _postJson(
      '/api/v1/auth/register',
      body: {
        'userName': userName,
        'email': email,
        'password': password,
        if (loginId != null && loginId.isNotEmpty) 'loginId': loginId,
      },
    );

    return _authUserFromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthUser> updateProfile({
    required String loginId,
    required String userName,
    required String email,
    required String publicName,
    String? photoAssetPath,
  }) async {
    final payload = await _patchJson(
      '/api/v1/profile',
      body: {
        'loginId': loginId,
        'userName': userName,
        'email': email,
        'publicName': publicName,
        if (photoAssetPath != null && photoAssetPath.isNotEmpty)
          'photoAssetPath': photoAssetPath,
      },
    );

    return _authUserFromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateAlertSettings({
    required String loginId,
    required AlertSettings settings,
  }) async {
    await _patchJson(
      '/api/v1/settings',
      body: {
        'loginId': loginId,
        'distanceMeters': settings.distanceMeters,
        'disconnectMinutes': settings.disconnectMinutes,
        'vibrationEnabled': settings.vibrationEnabled,
        'soundEnabled': settings.soundEnabled,
        'autoApprovePhotos': settings.autoApprovePhotos,
        'keepPhotoPrivateByDefault': settings.keepPhotoPrivateByDefault,
      },
    );
  }

  @override
  Future<void> saveSafeZone({
    required String loginId,
    required SafeZone zone,
  }) async {
    final path = zone.id.isEmpty ? '/api/v1/safe-zones' : '/api/v1/safe-zones/${zone.id}';
    final method = zone.id.isEmpty ? _postJson : _patchJson;
    await method(
      path,
      body: {
        'loginId': loginId,
        'name': zone.name,
        'address': zone.address,
        'radiusMeters': zone.radiusMeters,
      },
    );
  }

  @override
  Future<void> updateReward({
    required String loginId,
    required String itemId,
    required int reward,
  }) async {
    await _patchJson(
      '/api/v1/lost-items/$itemId/reward',
      body: {
        'loginId': loginId,
        'reward': reward,
      },
    );
  }

  @override
  Future<String> openOrCreateChat({
    required String loginId,
    required String itemId,
  }) async {
    final payload = await _postJson(
      '/api/v1/chat-threads',
      body: {
        'loginId': loginId,
        'itemId': itemId,
      },
    );

    return payload['threadId'] as String? ?? '';
  }

  @override
  Future<void> markChatThreadRead({
    required String loginId,
    required String threadId,
  }) async {
    await _postJson(
      '/api/v1/chat-threads/$threadId/read',
      body: {'loginId': loginId},
    );
  }

  @override
  Future<void> sendMessage({
    required String loginId,
    required String threadId,
    required String text,
  }) async {
    await _postJson(
      '/api/v1/chat-threads/$threadId/messages',
      body: {
        'loginId': loginId,
        'text': text,
      },
    );
  }

  @override
  Future<void> requestPhotoApproval({
    required String loginId,
    required String threadId,
  }) async {
    await _postJson(
      '/api/v1/chat-threads/$threadId/photo-request',
      body: {'loginId': loginId},
    );
  }

  @override
  Future<void> approvePhoto({
    required String loginId,
    required String threadId,
  }) async {
    await _postJson(
      '/api/v1/chat-threads/$threadId/approve-photo',
      body: {'loginId': loginId},
    );
  }

  @override
  Future<void> submitReport({
    required String loginId,
    required String threadId,
    required String reason,
  }) async {
    await _postJson(
      '/api/v1/chat-threads/$threadId/reports',
      body: {
        'loginId': loginId,
        'reason': reason,
      },
    );
  }

  Future<Map<String, dynamic>> _postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final baseUri = Uri.parse(_baseUrl);
    final uri = baseUri.resolve(path);
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final payload = _decodeMap(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(payload['message'] ?? '요청 처리에 실패했습니다.');
    }

    return payload;
  }

  Future<Map<String, dynamic>> _patchJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final baseUri = Uri.parse(_baseUrl);
    final uri = baseUri.resolve(path);
    final response = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final payload = _decodeMap(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(payload['message'] ?? '요청 처리에 실패했습니다.');
    }

    return payload;
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('응답 형식이 올바르지 않습니다.');
    }

    return decoded;
  }

  AuthUser _authUserFromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      loginId: json['loginId'] as String? ?? '',
      publicName: json['publicName'] as String? ?? '',
    );
  }
}
