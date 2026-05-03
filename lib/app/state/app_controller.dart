import 'dart:async';
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
  }) : _state = initialState,
       _repository = repository,
       _sessionStore = sessionStore,
       _activeLoginId = activeLoginId;

  static Future<AppController> create({
    AppRepository? repository,
    SessionStore? sessionStore,
  }) async {
    final resolvedSessionStore = sessionStore ?? SharedPrefsSessionStore();
    final resolvedRepository = repository ?? _resolveRepository();
    final activeLoginId = await resolvedSessionStore.readLoginId();

    return AppController(
      initialState: resolvedRepository.loadInitialState(),
      repository: resolvedRepository,
      sessionStore: resolvedSessionStore,
      activeLoginId: activeLoginId,
    );
  }

  static AppRepository _resolveRepository() {
    if (!AppConfig.hasApiBaseUrl) {
      return const ApiUnavailableRepository();
    }
    return ApiAppRepository();
  }

  AppState _state;
  final AppRepository _repository;
  final SessionStore _sessionStore;
  String? _activeLoginId;

  AppState get state => _state;
  bool get isAuthenticated =>
      _activeLoginId != null && _activeLoginId!.isNotEmpty;

  Future<void> bootstrap() async {
    if (!isAuthenticated) {
      return;
    }

    try {
      final latestState = await _repository.loadLatestState(
        loginId: _activeLoginId,
      );
      if (latestState == null) {
        await _resetAuthenticationState();
        return;
      }
      _state = latestState;
      notifyListeners();
    } catch (_) {
      await _resetAuthenticationState();
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

    final latestState = await _repository.loadLatestState(
      loginId: authUser.loginId,
    );
    _state = latestState ?? _stateFromAuthenticatedUser(authUser);
    notifyListeners();
  }

  Future<void> saveCurrentLocation({
    required double latitude,
    required double longitude,
    double? accuracyMeters,
  }) async {
    final loginId = _requireActiveLoginId();
    final currentLocation = await _repository.upsertCurrentLocation(
      loginId: loginId,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
    );
    _state = _state.copyWith(currentLocation: currentLocation);
    notifyListeners();
  }

  AppState _stateFromAuthenticatedUser(AuthUser authUser) {
    final userName = authUser.userName.trim();
    final initials = userName.isEmpty ? '사' : userName.substring(0, 1);

    return _repository.loadInitialState().copyWith(
      userProfile: UserProfile(
        id: authUser.id,
        name: authUser.userName,
        email: authUser.email,
        loginId: authUser.loginId,
        initials: initials,
        photoAssetPath: AppAssets.icon,
        publicName: authUser.publicName,
      ),
    );
  }

  Future<void> _resetAuthenticationState() async {
    _activeLoginId = null;
    await _sessionStore.clearLoginId();
    _state = _repository.loadInitialState();
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
    bool preserveLocalChatThreads = false,
    bool preserveLocalReports = false,
  }) async {
    final resolvedLoginId = loginId ?? _requireActiveLoginId();
    final preservedChatThreads = preserveLocalChatThreads
        ? List<ChatThread>.from(_state.chatThreads)
        : const <ChatThread>[];
    final preservedReports = preserveLocalReports
        ? List<ReportRecord>.from(_state.reports)
        : const <ReportRecord>[];
    final latestState = await _repository.loadLatestState(
      loginId: resolvedLoginId,
    );
    if (latestState == null) {
      return;
    }
    if (preserveLocalChatThreads && preservedChatThreads.isNotEmpty) {
      final remoteThreadIds = latestState.chatThreads
          .map((thread) => thread.id)
          .toSet();
      final localThreadsById = {
        for (final thread in preservedChatThreads) thread.id: thread,
      };
      final mergedThreads = [
        ...latestState.chatThreads.map(
          (thread) => localThreadsById[thread.id] ?? thread,
        ),
        ...preservedChatThreads.where(
          (thread) => !remoteThreadIds.contains(thread.id),
        ),
      ];
      _state = latestState.copyWith(chatThreads: mergedThreads);
    } else {
      _state = latestState;
    }
    if (preserveLocalReports && preservedReports.isNotEmpty) {
      final remoteReportKeys = latestState.reports
          .map(_reportKey)
          .toSet();
      final localReportsByKey = {
        for (final report in preservedReports) _reportKey(report): report,
      };
      final mergedReports = [
        ...latestState.reports.map(
          (report) => localReportsByKey[_reportKey(report)] ?? report,
        ),
        ...preservedReports.where(
          (report) => !remoteReportKeys.contains(_reportKey(report)),
        ),
      ];
      _state = _state.copyWith(reports: mergedReports);
    }
    _activeLoginId = latestState.userProfile.loginId;
    notifyListeners();
  }

  String _reportKey(ReportRecord report) {
    return '${report.targetTitle}::${report.reason}::${report.statusLabel}';
  }

  void _syncChatAction(Future<void> Function() action) {
    unawaited(() async {
      try {
        await action();
      } catch (_) {
        // 채팅 액션은 먼저 로컬에 반영하고, 서버 실패는 조용히 흡수한다.
      }
    }());
  }

  void _applyLocalChatThreadUpdate(
    String threadId,
    ChatThread Function(ChatThread thread) transformThread,
  ) {
    _state = _state.copyWith(
      chatThreads: _state.chatThreads.map((thread) {
        if (thread.id != threadId) {
          return thread;
        }
        return transformThread(thread);
      }).toList(),
    );
    notifyListeners();
  }

  void _appendChatSystemMessage({
    required String threadId,
    required String text,
    required ChatMessageType type,
  }) {
    _applyLocalChatThreadUpdate(threadId, (thread) {
      final nextMessage = ChatMessage(
        id: Formatters.uniqueId('msg'),
        text: text,
        sender: ChatSender.system,
        timeLabel: '방금 전',
        type: type,
      );
      final nextPhotoStatus = switch (type) {
        ChatMessageType.photoRequest => PhotoAccessStatus.pending,
        ChatMessageType.photoApproved => PhotoAccessStatus.approved,
        _ => thread.photoStatus,
      };
      return thread.copyWith(
        lastMessage: text,
        lastTime: '방금 전',
        unread: 0,
        photoStatus: nextPhotoStatus,
        messages: [...thread.messages, nextMessage],
      );
    });
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
        return item.copyWith(timeLabel: '방금 갱신', distance: distanceLabel);
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

  Future<void> saveBleDevice(BleDevice device) async {
    final loginId = _requireActiveLoginId();
    final index = _state.myDevices.indexWhere((item) => item.id == device.id);
    await _repository.saveBleDevice(
      loginId: loginId,
      device: device,
      isNew: index < 0,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> markChatThreadRead(String threadId) async {
    final loginId = _requireActiveLoginId();
    await _repository.markChatThreadRead(loginId: loginId, threadId: threadId);
    await _refreshRemoteState(
      loginId: loginId,
      preserveLocalChatThreads: true,
    );
  }

  Future<void> testBleDevice(String deviceId) async {
    final deviceIndex = _state.myDevices.indexWhere(
      (item) => item.id == deviceId,
    );
    if (deviceIndex < 0) {
      return;
    }
    final device = _state.myDevices[deviceIndex];
    final loginId = _requireActiveLoginId();
    unawaited(
      _repository.refreshBleSignal(loginId: loginId, deviceId: deviceId),
    );
    _state = _state.copyWith(
      myDevices: _state.myDevices.map((item) {
        if (item.id != deviceId) {
          return item;
        }
        return item.copyWith(
          status: ItemStatus.safe,
          lastSeen: '방금 전',
          lastSignalAt: DateTime.now().toIso8601String(),
        );
      }).toList(),
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

  Future<void> saveLostItem({
    required String title,
    required String location,
    required int reward,
    required String description,
    String? photoAssetPath,
  }) async {
    final loginId = _requireActiveLoginId();
    await _repository.createLostItem(
      loginId: loginId,
      title: title,
      location: location,
      reward: reward,
      description: description,
      photoAssetPath: photoAssetPath,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> saveFoundItem({
    required String title,
    required String location,
    required String description,
    String? photoAssetPath,
  }) async {
    final loginId = _requireActiveLoginId();
    await _repository.createFoundItem(
      loginId: loginId,
      title: title,
      location: location,
      description: description,
      photoAssetPath: photoAssetPath,
    );
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> searchListings({
    required String query,
    ListingType? itemType,
  }) async {
    final loginId = _requireActiveLoginId();
    final results = await _repository.searchListings(
      loginId: loginId,
      query: query,
      itemType: itemType,
    );
    _state = _state.copyWith(searchResults: results);
    notifyListeners();
  }

  Future<void> refreshMatches() async {
    final loginId = _requireActiveLoginId();
    final matches = await _repository.loadMatches(loginId: loginId);
    _state = _state.copyWith(suggestedMatches: matches);
    notifyListeners();
  }

  Future<void> submitInquiry({
    required InquiryCategory category,
    required String title,
    required String body,
    ListingType? relatedItemType,
    String? relatedItemId,
  }) async {
    final loginId = _requireActiveLoginId();
    await _repository.submitInquiry(
      loginId: loginId,
      category: category,
      title: title,
      body: body,
      relatedItemType: relatedItemType,
      relatedItemId: relatedItemId,
    );
    await _refreshRemoteState(loginId: loginId);
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
    await _repository.saveSafeZone(loginId: loginId, zone: zone);
    await _refreshRemoteState(loginId: loginId);
  }

  Future<void> updateAlertSettings(AlertSettings settings) async {
    final loginId = _requireActiveLoginId();
    await _repository.updateAlertSettings(loginId: loginId, settings: settings);
    await _refreshRemoteState(loginId: loginId);
  }

  Future<String> openOrCreateChatForItem(String itemId) async {
    final loginId = _requireActiveLoginId();
    final item = _state.lostItems.where((entry) => entry.id == itemId).toList();
    final threadId = await _repository.openOrCreateChat(
      loginId: loginId,
      itemId: itemId,
    );
    if (threadId.isEmpty) {
      throw Exception('채팅방을 열지 못했습니다.');
    }

    try {
      await _refreshRemoteState(loginId: loginId);
    } catch (_) {
      // 원격 동기화가 늦어도 채팅창은 바로 열리도록 로컬 상태를 유지한다.
    }

    final hasVisibleThread = _state.chatThreads.any((thread) => thread.id == threadId);
    if (!hasVisibleThread && item.isNotEmpty) {
      final lostItem = item.first;
      final existingThreads = _state.chatThreads.where((thread) => thread.id != threadId).toList();
      _state = _state.copyWith(
        chatThreads: [
          _optimisticThreadForItem(
            threadId: threadId,
            item: lostItem,
          ),
          ...existingThreads,
        ],
        currentTab: AppTab.chat,
      );
      notifyListeners();
      return threadId;
    }

    _state = _state.copyWith(currentTab: AppTab.chat);
    notifyListeners();
    return threadId;
  }

  ChatThread _optimisticThreadForItem({
    required String threadId,
    required LostItem item,
  }) {
    return ChatThread(
      id: threadId,
      itemId: item.id,
      itemTitle: item.title,
      itemStatus: item.status,
      lastMessage: '안녕하세요. ${item.title} 관련해서 메시지를 보냈습니다.',
      lastTime: '방금 전',
      unread: 0,
      photoStatus: item.photoStatus,
      otherUser: item.ownerName,
      reward: item.reward,
      messages: [
        ChatMessage(
          id: Formatters.uniqueId('msg'),
          text: '안녕하세요. ${item.title} 관련해서 메시지를 보냈습니다.',
          sender: ChatSender.me,
          timeLabel: '방금 전',
          type: ChatMessageType.text,
        ),
      ],
    );
  }

  Future<void> sendMessage(String threadId, String text) async {
    final loginId = _requireActiveLoginId();
    _applyLocalChatThreadUpdate(threadId, (thread) {
      final nextMessage = ChatMessage(
        id: Formatters.uniqueId('msg'),
        text: text,
        sender: ChatSender.me,
        timeLabel: '방금 전',
        type: ChatMessageType.text,
      );
      return thread.copyWith(
        lastMessage: text,
        lastTime: '방금 전',
        unread: 0,
        messages: [...thread.messages, nextMessage],
      );
    });
    _syncChatAction(
      () => _repository.sendMessage(
        loginId: loginId,
        threadId: threadId,
        text: text,
      ),
    );
  }

  Future<void> requestPhotoApproval(String threadId) async {
    final loginId = _requireActiveLoginId();
    _appendChatSystemMessage(
      threadId: threadId,
      text: '사진 열람을 요청했습니다. 주인의 승인을 기다리는 중입니다.',
      type: ChatMessageType.photoRequest,
    );
    _syncChatAction(
      () => _repository.requestPhotoApproval(
        loginId: loginId,
        threadId: threadId,
      ),
    );
  }

  Future<void> approvePhoto(String threadId) async {
    final loginId = _requireActiveLoginId();
    _appendChatSystemMessage(
      threadId: threadId,
      text: '주인이 사진 열람을 허용했습니다.',
      type: ChatMessageType.photoApproved,
    );
    _syncChatAction(
      () => _repository.approvePhoto(loginId: loginId, threadId: threadId),
    );
  }

  Future<void> submitReport({
    required String threadId,
    required String reason,
  }) async {
    final loginId = _requireActiveLoginId();
    final thread = _state.chatThreads
        .where((item) => item.id == threadId)
        .toList();
    final targetTitle = thread.isEmpty ? '채팅방' : '${thread.first.itemTitle} 채팅방';
    _state = _state.copyWith(
      reports: [
        ReportRecord(
          id: Formatters.uniqueId('r'),
          targetTitle: targetTitle,
          reason: reason,
          createdAtLabel: '방금 전',
          statusLabel: '접수 완료',
        ),
        ..._state.reports,
      ],
    );
    notifyListeners();
    _appendChatSystemMessage(
      threadId: threadId,
      text: '비매너 유저 신고가 접수되었습니다.',
      type: ChatMessageType.report,
    );
    _syncChatAction(
      () => _repository.submitReport(
        loginId: loginId,
        threadId: threadId,
        reason: reason,
      ),
    );
  }
}
