import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';

import 'support/fake_app_repository.dart';
import 'support/fake_session_store.dart';

class _HomeChatRepository extends FakeAppRepository {
  _HomeChatRepository()
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
        );

  final AppState _state;

  @override
  AppState loadInitialState() => _state;

  @override
  Future<AppState?> loadLatestState({String? loginId}) async => _state;

  @override
  Future<String> openOrCreateChat({
    required String loginId,
    required String itemId,
  }) async {
    return 'thread-$itemId';
  }
}

void main() {
  test('홈에서 채팅을 열면 스레드가 즉시 보이도록 보강된다', () async {
    final repository = _HomeChatRepository();
    final controller = AppController(
      initialState: repository.loadInitialState(),
      repository: repository,
      sessionStore: FakeSessionStore(),
      activeLoginId: 'tester@example.com',
    );

    final threadId = await controller.openOrCreateChatForItem('lost-1');

    expect(threadId, 'thread-lost-1');
    expect(controller.state.currentTab, AppTab.chat);
    expect(controller.state.chatThreads, isNotEmpty);
    expect(controller.state.chatThreads.first.id, 'thread-lost-1');
    expect(controller.state.chatThreads.first.messages, isNotEmpty);

    await controller.sendMessage('thread-lost-1', '연락 부탁드립니다.');
    final afterSend = controller.state.chatThreads.firstWhere(
      (thread) => thread.id == 'thread-lost-1',
    );
    expect(afterSend.messages.last.text, '연락 부탁드립니다.');
    expect(afterSend.lastMessage, '연락 부탁드립니다.');

    await controller.requestPhotoApproval('thread-lost-1');
    final afterRequest = controller.state.chatThreads.firstWhere(
      (thread) => thread.id == 'thread-lost-1',
    );
    expect(afterRequest.photoStatus, PhotoAccessStatus.pending);
    expect(afterRequest.messages.last.type, ChatMessageType.photoRequest);

    await controller.approvePhoto('thread-lost-1');
    final afterApprove = controller.state.chatThreads.firstWhere(
      (thread) => thread.id == 'thread-lost-1',
    );
    expect(afterApprove.photoStatus, PhotoAccessStatus.approved);
    expect(afterApprove.messages.last.type, ChatMessageType.photoApproved);

    await controller.submitReport(
      threadId: 'thread-lost-1',
      reason: '테스트 신고',
    );
    expect(
      controller.state.reports.any((report) => report.reason == '테스트 신고'),
      isTrue,
    );
    expect(
      controller.state.chatThreads
          .firstWhere((thread) => thread.id == 'thread-lost-1')
          .messages
          .last
          .type,
      ChatMessageType.report,
    );

    await controller.markChatThreadRead('thread-lost-1');

    expect(controller.state.chatThreads, isNotEmpty);
    expect(controller.state.chatThreads.first.id, 'thread-lost-1');
  });
}
