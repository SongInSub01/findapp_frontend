import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:my_flutter_starter/core/config/app_config.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/repositories/app_repository.dart';
import 'package:my_flutter_starter/data/sources/app_state_json_mapper.dart';

/// 찾아줘 백엔드 API와 직접 통신하는 실제 저장소 구현체다.
class ApiAppRepository implements AppRepository {
  ApiAppRepository({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  @override
  AppState loadInitialState() => AppState.empty();

  @override
  Future<AppState?> loadLatestState({String? loginId}) async {
    if (_baseUrl.isEmpty || loginId == null || loginId.isEmpty) {
      return null;
    }

    final baseUri = Uri.parse(_baseUrl);
    final uri = baseUri
        .resolve('/api/v1/bootstrap')
        .replace(queryParameters: {'loginId': loginId});
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
      body: {'loginId': loginId, 'password': password},
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
        if (loginId?.isNotEmpty ?? false) 'loginId': loginId,
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
        if (photoAssetPath?.isNotEmpty ?? false)
          'photoAssetPath': photoAssetPath,
      },
    );

    return _authUserFromJson(payload['user'] as Map<String, dynamic>);
  }

  @override
  Future<CurrentLocation> upsertCurrentLocation({
    required String loginId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  }) async {
    final accuracyBody = accuracyMeters == null
        ? <String, dynamic>{}
        : {'accuracyMeters': accuracyMeters};
    final payload = await _putJson(
      '/api/v1/location',
      body: {
        'loginId': loginId,
        'latitude': latitude,
        'longitude': longitude,
        ...accuracyBody,
      },
    );

    return _currentLocationFromJson(
      payload['currentLocation'] as Map<String, dynamic>,
    );
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
        'defaultReward': settings.defaultReward,
        'mapTheme': settings.mapTheme.name,
      },
    );
  }

  @override
  Future<void> saveSafeZone({
    required String loginId,
    required SafeZone zone,
  }) async {
    final path = zone.id.isEmpty
        ? '/api/v1/safe-zones'
        : '/api/v1/safe-zones/${zone.id}';
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
  Future<void> saveBleDevice({
    required String loginId,
    required BleDevice device,
    required bool isNew,
  }) async {
    final body = {
      'loginId': loginId,
      'name': device.name,
      'iconKey': device.iconKey,
      'status': _itemStatusToJson(device.status),
      'location': device.location,
      'lastSeen': device.lastSeen,
      'bleCode': device.bleCode,
      'lastSignalAt': device.lastSignalAt,
      'bleStatus': device.bleStatus.name,
      'mapX': device.mapX,
      'mapY': device.mapY,
      'distance': device.distance,
      'reward': device.reward,
      'photoAssetPath': device.photoAssetPath,
    };

    if (isNew) {
      await _postJson('/api/v1/devices', body: body);
      return;
    }

    await _patchJson('/api/v1/devices/${device.id}', body: body);
  }

  @override
  Future<void> createLostItem({
    required String loginId,
    required String title,
    required String location,
    required int reward,
    required String description,
    String? photoAssetPath,
  }) async {
    final trimmedDescription = description.trim();
    final resolvedDescription = trimmedDescription.isEmpty
        ? 'BLE 감지 후 등록된 분실물입니다.'
        : trimmedDescription;
    final images = (photoAssetPath == null || photoAssetPath.isEmpty)
        ? const <Map<String, dynamic>>[]
        : [
            {
              'imageUrl': photoAssetPath,
              'fileName': photoAssetPath.split('/').last,
              'mimeType': 'image/png',
              'isPrimary': true,
            },
          ];

    await _postJson(
      '/api/v1/lost-items',
      body: {
        'loginId': loginId,
        'title': title,
        'category': '일반 물건',
        'color': '확인 필요',
        'location': location,
        'happenedAt': DateTime.now().toIso8601String(),
        'reward': reward,
        'listingStatus': 'open',
        'description': resolvedDescription,
        'featureNotes': resolvedDescription,
        'contactNote': '앱 채팅으로 연락해 주세요.',
        'images': images,
      },
    );
  }

  @override
  Future<void> createFoundItem({
    required String loginId,
    required String title,
    required String location,
    required String description,
    String? photoAssetPath,
  }) async {
    final trimmedDescription = description.trim();
    final resolvedDescription = trimmedDescription.isEmpty
        ? '앱에서 등록한 습득물입니다.'
        : trimmedDescription;
    final images = (photoAssetPath == null || photoAssetPath.isEmpty)
        ? const <Map<String, dynamic>>[]
        : [
            {
              'imageUrl': photoAssetPath,
              'fileName': photoAssetPath.split('/').last,
              'mimeType': 'image/png',
              'isPrimary': true,
            },
          ];

    await _postJson(
      '/api/v1/found-items',
      body: {
        'loginId': loginId,
        'title': title,
        'category': '일반 물건',
        'color': '확인 필요',
        'location': location,
        'happenedAt': DateTime.now().toIso8601String(),
        'listingStatus': 'open',
        'description': resolvedDescription,
        'featureNotes': resolvedDescription,
        'storageNote': '습득자가 보관 중입니다.',
        'contactNote': '앱 문의로 연락해 주세요.',
        'images': images,
      },
    );
  }

  @override
  Future<List<ListingSummary>> searchListings({
    required String loginId,
    required String query,
    ListingType? itemType,
  }) async {
    final baseUri = Uri.parse(_baseUrl);
    final resolvedType = switch (itemType) {
      ListingType.lost => 'lost',
      ListingType.found => 'found',
      null => 'all',
    };
    final uri = baseUri
        .resolve('/api/v1/search')
        .replace(
          queryParameters: {
            'loginId': loginId,
            'itemType': resolvedType,
            if (query.trim().isNotEmpty) 'q': query.trim(),
          },
        );
    final response = await _client.get(uri);
    final payload = _decodeMap(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(payload['message'] ?? '검색에 실패했습니다.');
    }
    return ((payload['items'] as List<dynamic>?) ?? const [])
        .map((item) => _listingSummaryFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MatchRecord>> loadMatches({required String loginId}) async {
    final baseUri = Uri.parse(_baseUrl);
    final uri = baseUri
        .resolve('/api/v1/matches')
        .replace(queryParameters: {'loginId': loginId});
    final response = await _client.get(uri);
    final payload = _decodeMap(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(payload['message'] ?? '매칭 목록을 불러오지 못했습니다.');
    }
    return ((payload['matches'] as List<dynamic>?) ?? const [])
        .map((item) => _matchFromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> submitInquiry({
    required String loginId,
    required InquiryCategory category,
    required String title,
    required String body,
    ListingType? relatedItemType,
    String? relatedItemId,
  }) async {
    await _postJson(
      '/api/v1/inquiries',
      body: {
        'loginId': loginId,
        'category': category.name,
        'title': title,
        'body': body,
        if (relatedItemType != null) 'relatedItemType': relatedItemType.name,
        if (relatedItemId?.isNotEmpty ?? false) 'relatedItemId': relatedItemId,
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
      body: {'loginId': loginId, 'reward': reward},
    );
  }

  @override
  Future<void> refreshBleSignal({
    required String loginId,
    required String deviceId,
  }) async {
    await _postJson(
      '/api/v1/devices/$deviceId/signal',
      body: {'loginId': loginId, 'rssi': -58, 'focusMinutes': 5},
    );
  }

  @override
  Future<String> openOrCreateChat({
    required String loginId,
    required String itemId,
  }) async {
    final payload = await _postJson(
      '/api/v1/chat-threads',
      body: {'loginId': loginId, 'itemId': itemId},
    );

    final threadId = payload['threadId'] as String? ?? '';
    if (threadId.isEmpty) {
      throw Exception('채팅방을 열지 못했습니다.');
    }
    return threadId;
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
      body: {'loginId': loginId, 'text': text},
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
      body: {'loginId': loginId, 'reason': reason},
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

  Future<Map<String, dynamic>> _putJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final baseUri = Uri.parse(_baseUrl);
    final uri = baseUri.resolve(path);
    final response = await _client.put(
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
    final body = response.body.trimLeft();
    if (body.isEmpty || (body[0] != '{' && body[0] != '[')) {
      throw Exception('백엔드가 JSON이 아닌 응답을 반환했습니다. APP_API_BASE_URL을 확인해 주세요.');
    }

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

  CurrentLocation _currentLocationFromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  ListingSummary _listingSummaryFromJson(Map<String, dynamic> json) {
    return ListingSummary(
      id: json['id'] as String? ?? '',
      itemType: (json['itemType'] as String?) == 'found'
          ? ListingType.found
          : ListingType.lost,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      location: json['location'] as String? ?? '',
      happenedAt: json['happenedAt'] as String? ?? '',
      happenedAtLabel: json['happenedAtLabel'] as String? ?? '',
      listingStatus: _listingStatusFromJson(json['listingStatus'] as String?),
      description: json['description'] as String? ?? '',
      featureNotes: json['featureNotes'] as String? ?? '',
      contactNote: json['contactNote'] as String? ?? '',
      ownerDisplayName: json['ownerDisplayName'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      reward: (json['reward'] as num?)?.toInt(),
      matchCount: (json['matchCount'] as num?)?.toInt() ?? 0,
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  MatchRecord _matchFromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      matchStatus: _matchStatusFromJson(json['matchStatus'] as String?),
      reasonSummary: json['reasonSummary'] as String? ?? '',
      lostItem: _listingSummaryFromJson(
        (json['lostItem'] as Map<String, dynamic>?) ?? const {},
      ),
      foundItem: _listingSummaryFromJson(
        (json['foundItem'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  ListingWorkflowStatus _listingStatusFromJson(String? value) {
    switch (value) {
      case 'matched':
        return ListingWorkflowStatus.matched;
      case 'resolved':
        return ListingWorkflowStatus.resolved;
      case 'archived':
        return ListingWorkflowStatus.archived;
      case 'open':
      default:
        return ListingWorkflowStatus.open;
    }
  }

  MatchStatus _matchStatusFromJson(String? value) {
    switch (value) {
      case 'reviewing':
        return MatchStatus.reviewing;
      case 'confirmed':
        return MatchStatus.confirmed;
      case 'dismissed':
        return MatchStatus.dismissed;
      case 'suggested':
      default:
        return MatchStatus.suggested;
    }
  }

  String _itemStatusToJson(ItemStatus status) {
    switch (status) {
      case ItemStatus.safe:
        return 'safe';
      case ItemStatus.contact:
        return 'contact';
      case ItemStatus.lost:
        return 'lost';
    }
  }
}
