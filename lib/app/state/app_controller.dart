import 'dart:math';

import 'package:flutter/material.dart';

import 'package:my_flutter_starter/core/config/app_config.dart';
import 'package:my_flutter_starter/core/storage/session_store.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/repositories/api_app_repository.dart';
import 'package:my_flutter_starter/data/repositories/api_unavailable_repository.dart';
import 'package:my_flutter_starter/data/repositories/app_repository.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';

/// 앱 전역 상태와 인증 흐름을 함께 관리하는 메인 컨트롤러다.
class AppController extends ChangeNotifier {
  AppController({
    required AppState initialState,
    required AppRepository repository,
    required SessionStore sessionStore,
    String? activeLoginId,
  })  : _state = initialState,
        _repository = repository,
        _sessionStore = sessionStore,
        _activeLoginId = activeLoginId;

  static Future<AppController> create({
    AppRepository? repository,
    SessionStore? sessionStore,
  }) async {
    final resolvedSessionStore = sessionStore ?? SharedPrefsSessionStore();
    final resolvedRepository = repository ??
        (AppConfig.hasApiBaseUrl
            ? ApiAppRepository()
            : const ApiUnavailableRepository());
    final activeLoginId = await resolvedSessionStore.readLoginId();

    return AppController(
      initialState: resolvedRepository.loadInitialState(),
      repository: resolvedRepository,
      sessionStore: resolvedSessionStore,
      activeLoginId: activeLoginId,
    );
  }

  AppState _state;
  final AppRepository _repository;
  final SessionStore _sessionStore;
  String? _activeLoginId;

  AppState get state => _state;
  bool get isAuthenticated => _activeLoginId != null && _activeLoginId!.isNotEmpty;

  Future<void> bootstrap() async {
    if (!isAuthenticated) {
      return;
    }

    try {
      final latestState = await _repository.loadLatestState(loginId: _activeLoginId);
      if (latestState == null) {
        return;
      }
      _state = latestState;
      notifyListeners();
    } catch (_) {
      // Keep mock state when remote bootstrap is unavailable.
    }
  }

  Future<String> signIn({
    required String loginId,
    required String password,
    required bool rememberMe,
  }) async {
    final authUser = await _repository.login(
      loginId: loginId,
      password: password,
    );
    await _applyAuthenticatedUser(authUser, rememberMe: rememberMe);
    return authUser.userName;
  }

  Future<String> signUp({
    required String userName,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final authUser = await _repository.register(
      userName: userName,
      email: email,
      password: password,
    );
    await _applyAuthenticatedUser(authUser, rememberMe: rememberMe);
    return authUser.userName;
  }

  Future<void> _applyAuthenticatedUser(
    AuthUser authUser, {
    required bool rememberMe,
  }) async {
    _activeLoginId = authUser.loginId;

    if (rememberMe) {
      await _sessionStore.saveLoginId(authUser.loginId);
    } else {
      await _sessionStore.clearLoginId();
    }

    final latestState = await _repository.loadLatestState(loginId: authUser.loginId);
    _state = latestState ?? _repository.loadInitialState();
    notifyListeners();
  }

  Future<void> signOut() async {
    _activeLoginId = null;
    await _sessionStore.clearLoginId();
    _state = _repository.loadInitialState();
    notifyListeners();
  }

  String _requireActiveLoginId() {
    final loginId = _activeLoginId;
    if (loginId == null || loginId.isEmpty) {
      throw Exception('로그인이 필요한 기능입니다.');
    }
    return loginId;
  }

  Future<void> _refreshRemoteState({
    String? loginId,
  }) async {
    final resolvedLoginId = loginId ?? _requireActiveLoginId();
    final latestState = await _repository.loadLatestState(loginId: resolvedLoginId);
    if (latestState == null) {
      return;
    }
    _state = latestState;
    _activeLoginId = latestState.userProfile.loginId;
    notifyListeners();
  }

  Future<void> _syncStoredLoginIdIfNeeded(String loginId) async {
    final storedLoginId = await _sessionStore.readLoginId();
    if (storedLoginId != null && storedLoginId.isNotEmpty) {
      await _sessionStore.saveLoginId(loginId);
    }
  }

  void switchTab(AppTab tab) {
    _state = _state.copyWith(currentTab: tab);
    notifyListeners();
  }

  void openMapForTarget(String targetId) {
    _state = _state.copyWith(
      currentTab: AppTab.map,
      selectedMapTargetId: targetId,
    );
    notifyListeners();
  }

  void clearMapSelection() {
    _state = _state.copyWith(clearSelectedMapTarget: true);
    notifyListeners();
  }

  void dismissFalseAlarm(String deviceId) {
    _state = _state.copyWith(
      myDevices: _state.myDevices.map((device) {
        if (device.id != deviceId) {
          return device;
        }
        return device.copyWith(
          status: ItemStatus.safe,
          location: '내 주변 (1m)',
          lastSeen: '방금 전',
          distance: '1m',
        );
      }).toList(),
      notifications: [
        NotificationItem(
          id: Formatters.uniqueId('n'),
          title: '오알림 처리 완료',
          body: 'BLE 신호 재확인 후 분실 경고를 해제했습니다.',
          timeLabel: '방금 전',
          type: NotificationType.info,
          isRead: false,
        ),
        ..._state.notifications,
      ],
    );
    notifyListeners();
  }

  void markNotificationsRead() {
    _state = _state.copyWith(
      notifications: _state.notifications
          .map((item) => item.copyWith(isRead: true))
          .toList(),
    );
    notifyListeners();
  }

  void refreshNearbyItems() {
    final random = Random();
    _state = _state.copyWith(
      lostItems: _state.lostItems.map((item) {
        final nextDistance = (random.nextDouble() * 2.4) + 0.1;
        final distanceLabel = nextDistance >= 1
            ? '${nextDistance.toStringAsFixed(1)}km'
            : '${(nextDistance * 1000).round()}m';
        return item.copyWith(
          timeLabel: '방금 갱신',
          distance: distanceLabel,
        );
      }).toList(),
      notifications: [
        NotificationItem(
          id: Formatters.uniqueId('n'),
          title: '주변 탐색 갱신 완료',
          body: 'BLE 주변 탐색 결과와 거리 정보가 최신 상태로 반영되었습니다.',
          timeLabel: '방금 전',
          type: NotificationType.info,
          isRead: false,
        ),
        ..._state.notifications,
      ],
    );
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String publicName,
    String? photoAssetPath,
  }) async {
    final loginId = _requireActiveLoginId();
    final updatedUser = await _repository.updateProfile(
      loginId: loginId,
      userName: name,
      email: email,
      publicName: publicName,
      photoAssetPath: photoAssetPath,
    );
    _activeLoginId = updatedUser.loginId;
    await _syncStoredLoginIdIfNeeded(updatedUser.loginId);
    await _refreshRemoteState(loginId: updatedUser.loginId);
  }

  void saveBleDevice(BleDevice device) {
    final index = _state.myDevices.indexWhere((item) => item.id == device.id);
    final devices = [..._state.myDevices];
    if (index >= 0) {
      devices[index] = device;
    } else {
      devices.add(device);
    }
    _state = _state.copyWith(myDevices: devices);
    notifyListeners();
  }

  Future<void> markChatThreadRead(String threadId) async {
    final loginId = _requireActiveLoginId();
    await _repository.markChatThreadRead(
      loginId: loginId,
      threadId: threadId,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  void testBleDevice(String deviceId) {
    final device = _state.myDevices.firstWhere((item) => item.id == deviceId);
    _state = _state.copyWith(
      notifications: [
        NotificationItem(
          id: Formatters.uniqueId('n'),
          title: '${device.name} 테스트 완료',
          body: '${device.bleCode} 센서와 정상적으로 통신했습니다.',
          timeLabel: '방금 전',
          type: NotificationType.info,
          isRead: false,
        ),
        ..._state.notifications,
      ],
    );
    notifyListeners();
  }

  void saveLostItem({
    required String title,
    required String location,
    required int reward,
    required String description,
    String? photoAssetPath,
  }) {
    final random = Random();
    final item = LostItem(
      id: Formatters.uniqueId('l'),
      title: title,
      location: location,
      timeLabel: '방금 전',
      reward: reward,
      status: ItemStatus.lost,
      photoStatus: _state.alertSettings.keepPhotoPrivateByDefault
          ? PhotoAccessStatus.locked
          : PhotoAccessStatus.approved,
      distance: '${(random.nextDouble() * 2 + 0.2).toStringAsFixed(1)}km',
      ownerName: _state.userProfile.publicName,
      description: description,
      mapX: 0.2 + random.nextDouble() * 0.55,
      mapY: 0.2 + random.nextDouble() * 0.55,
      photoAssetPath: photoAssetPath ?? AppAssets.splashIcon,
    );
    _state = _state.copyWith(
      lostItems: [item, ..._state.lostItems],
      notifications: [
        NotificationItem(
          id: Formatters.uniqueId('n'),
          title: '분실물 등록 완료',
          body: '$title 항목이 주변 탐색 목록에 추가되었습니다.',
          timeLabel: '방금 전',
          type: NotificationType.info,
          isRead: false,
        ),
        ..._state.notifications,
      ],
    );
    notifyListeners();
  }

  Future<void> updateReward(String itemId, int reward) async {
    final loginId = _requireActiveLoginId();
    await _repository.updateReward(
      loginId: loginId,
      itemId: itemId,
      reward: reward,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> saveSafeZone(SafeZone zone) async {
    final loginId = _requireActiveLoginId();
    await _repository.saveSafeZone(
      loginId: loginId,
      zone: zone,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> updateAlertSettings(AlertSettings settings) async {
    final loginId = _requireActiveLoginId();
    await _repository.updateAlertSettings(
      loginId: loginId,
      settings: settings,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<String> openOrCreateChatForItem(String itemId) async {
    final loginId = _requireActiveLoginId();
    final threadId = await _repository.openOrCreateChat(
      loginId: loginId,
      itemId: itemId,
    );
    await _refreshRemoteState(loginId: loginId);
    _state = _state.copyWith(currentTab: AppTab.chat);
    notifyListeners();
    return threadId;
  }

  Future<void> sendMessage(String threadId, String text) async {
    final loginId = _requireActiveLoginId();
    await _repository.sendMessage(
      loginId: loginId,
      threadId: threadId,
      text: text,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> requestPhotoApproval(String threadId) async {
    final loginId = _requireActiveLoginId();
    await _repository.requestPhotoApproval(
      loginId: loginId,
      threadId: threadId,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> approvePhoto(String threadId) async {
    final loginId = _requireActiveLoginId();
    await _repository.approvePhoto(
      loginId: loginId,
      threadId: threadId,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> submitReport({
    required String threadId,
    required String reason,
  }) async {
    final loginId = _requireActiveLoginId();
    await _repository.submitReport(
      loginId: loginId,
      threadId: threadId,
      reason: reason,
    );
    await _refreshRemoteState(loginId: loginId);
  }
}
