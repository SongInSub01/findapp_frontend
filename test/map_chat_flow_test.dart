import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/models/auth_models.dart';
import 'package:my_flutter_starter/data/repositories/app_repository.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_kakao_bridge.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_page_handler.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_view_models.dart';

import 'support/fake_session_store.dart';

class _MapChatFlowRepository implements AppRepository {
  _MapChatFlowRepository()
    : _state = AppState.empty().copyWith(
        userProfile: const UserProfile(
          id: 'u1',
          name: '테스트유저',
          email: 'tester@example.com',
          loginId: 'tester@example.com',
          initials: '테',
          photoAssetPath: 'assets/images/icon.png',
          publicName: '테**',
        ),
        lostItems: [
          const LostItem(
            id: 'lost-1',
            title: '버건디 백팩',
            location: '서울숲역 4번 출구',
            timeLabel: '35분 전',
            reward: 100000,
            status: ItemStatus.lost,
            photoStatus: PhotoAccessStatus.pending,
            distance: '70m',
            ownerName: '테**',
            description: '테스트용 분실물입니다.',
            sourceDeviceId: null,
            mapX: 0.42,
            mapY: 0.38,
            photoAssetPath: 'assets/images/splash_icon.png',
          ),
        ],
        chatThreads: const [],
      );

  AppState _state;

  @override
  AppState loadInitialState() => _state;

  @override
  Future<AppState?> loadLatestState({String? loginId}) async => _state;

  @override
  Future<AuthUser> login({
    required String loginId,
    required String password,
  }) async {
    return AuthUser(
      id: 'u1',
      userName: '테스트유저',
      email: loginId,
      loginId: loginId,
      publicName: '테**',
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
  }) async {
    final existing = _state.chatThreads
        .where((thread) => thread.itemId == itemId)
        .toList();
    if (existing.isNotEmpty) {
      return existing.first.id;
    }

    final thread = ChatThread(
      id: 'thread-$itemId',
      itemId: itemId,
      itemTitle: '버건디 백팩',
      itemStatus: ItemStatus.contact,
      lastMessage: '안녕하세요. 위치 확인 부탁드려요.',
      lastTime: '방금 전',
      unread: 0,
      photoStatus: PhotoAccessStatus.pending,
      otherUser: '버건디 백팩 주인',
      reward: 100000,
      messages: const [
        ChatMessage(
          id: 'msg-1',
          text: '안녕하세요. 위치 확인 부탁드려요.',
          sender: ChatSender.other,
          timeLabel: '방금 전',
          type: ChatMessageType.text,
        ),
      ],
    );
    _state = _state.copyWith(
      chatThreads: [thread, ..._state.chatThreads],
      currentTab: AppTab.chat,
    );
    return thread.id;
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
  }) async {
    final threads = _state.chatThreads.map((thread) {
      if (thread.id != threadId) {
        return thread;
      }
      final nextMessage = ChatMessage(
        id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
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
    }).toList();
    _state = _state.copyWith(chatThreads: threads, currentTab: AppTab.chat);
  }

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
  testWidgets('지도 카드 탭은 채팅으로 바로 이동하고 메시지를 보낼 수 있다', (tester) async {
    final repository = _MapChatFlowRepository();
    final controller = AppController(
      initialState: repository.loadInitialState(),
      repository: repository,
      sessionStore: FakeSessionStore(),
      activeLoginId: 'tester@example.com',
    );

    await controller.bootstrap();

    late MapPageHandler handler;

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          onGenerateRoute: AppRouteFactory.generate,
          home: Builder(
            builder: (context) {
              handler = MapPageHandler(
                context: context,
                controller: controller,
                state: controller.state,
                currentLocation: null,
                layerMode: MapLayerMode.city,
                onLayerModeChanged: (_) {},
                onMapControllerChanged: (_) {},
              );

              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    key: const Key('open-map-chat'),
                    onPressed: () {
                      unawaited(
                        handler.handleMarkerAction(
                          MapMarkerViewData(
                            id: 'lost-1',
                            name: '버건디 백팩',
                            subtitle: '서울숲역 4번 출구',
                            status: ItemStatus.lost,
                            latLng: LatLng(37.565, 126.978),
                            isMine: false,
                            distanceValue: 70,
                          ),
                        ),
                      );
                    },
                    child: const Text('채팅 열기'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-map-chat')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(controller.state.currentTab, AppTab.chat);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('버건디 백팩'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '위치 확인했습니다');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('위치 확인했습니다'), findsOneWidget);
    expect(
      controller.state.chatThreads
          .firstWhere((thread) => thread.id == 'thread-lost-1')
          .messages
          .last
          .text,
      '위치 확인했습니다',
    );
  });
}
