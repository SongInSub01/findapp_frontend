import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_kakao_bridge.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_view_models.dart';

void main() {
  test('연락 중은 실제 채팅 스레드가 있을 때만 표시된다', () {
    final state = AppState.empty().copyWith(
      lostItems: [
        LostItem(
          id: 'lost-no-thread',
          title: '연락 없는 분실물',
          location: '테스트 위치',
          timeLabel: '방금 전',
          reward: 10000,
          status: ItemStatus.contact,
          photoStatus: PhotoAccessStatus.locked,
          distance: '100m',
          ownerName: '테스트',
          description: 'thread 없이 contact로 남아 있던 항목',
          sourceDeviceId: null,
          mapX: 0.4,
          mapY: 0.5,
          threadId: null,
          photoAssetPath: null,
        ),
        LostItem(
          id: 'lost-with-thread',
          title: '실제 채팅 중인 분실물',
          location: '테스트 위치 2',
          timeLabel: '방금 전',
          reward: 20000,
          status: ItemStatus.lost,
          photoStatus: PhotoAccessStatus.pending,
          distance: '80m',
          ownerName: '테스트',
          description: 'thread가 연결된 항목',
          sourceDeviceId: null,
          mapX: 0.6,
          mapY: 0.5,
          threadId: 'thread-1',
          photoAssetPath: null,
        ),
      ],
      chatThreads: [
        const ChatThread(
          id: 'thread-1',
          itemId: 'lost-with-thread',
          itemTitle: '실제 채팅 중인 분실물',
          itemStatus: ItemStatus.contact,
          lastMessage: '안녕하세요',
          lastTime: '방금 전',
          unread: 0,
          photoStatus: PhotoAccessStatus.pending,
          otherUser: '테스트',
          reward: 20000,
          messages: [],
        ),
      ],
    );

    final markers = MapMarkerBuilder.fromState(
      state,
      anchorLatLng: LatLng(37.5665, 126.9780),
    );

    final noThreadMarker = markers.firstWhere((marker) => marker.id == 'lost-no-thread');
    final withThreadMarker = markers.firstWhere((marker) => marker.id == 'lost-with-thread');

    expect(resolveMapItemStatus(state.lostItems.first, hasActiveChat: false), ItemStatus.lost);
    expect(resolveMapItemStatus(state.lostItems.last, hasActiveChat: true), ItemStatus.contact);
    expect(noThreadMarker.status, ItemStatus.lost);
    expect(withThreadMarker.status, ItemStatus.contact);
  });
}
