import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/repositories/api_app_repository.dart';

import 'support/fake_session_store.dart';

void main() {
  const baseUrl = String.fromEnvironment('LIVE_API_BASE_URL');
  const seededLoginId = String.fromEnvironment(
    'LIVE_ACTION_LOGIN_ID',
    defaultValue: 'insub@example.com',
  );

  test('실제 API 쓰기 흐름이 Flutter 상태에 반영된다', () async {
    if (baseUrl.isEmpty) {
      return;
    }

    final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
    final controller = AppController(
      initialState: AppState.empty(),
      repository: ApiAppRepository(baseUrl: baseUrl),
      sessionStore: FakeSessionStore(),
      activeLoginId: seededLoginId,
    );

    await controller.bootstrap();

    final nextEmail = 'insub.action.$uniqueSuffix@example.com';
    await controller.updateProfile(
      name: '실연동$uniqueSuffix',
      email: nextEmail,
      publicName: '실**',
      photoAssetPath: 'assets/images/splash_icon.png',
    );
    expect(controller.state.userProfile.name, '실연동$uniqueSuffix');
    expect(controller.state.userProfile.loginId, nextEmail);

    await controller.updateAlertSettings(
      controller.state.alertSettings.copyWith(
        distanceMeters: 20,
        disconnectMinutes: 3,
        vibrationEnabled: false,
        autoApprovePhotos: true,
        keepPhotoPrivateByDefault: false,
      ),
    );
    expect(controller.state.alertSettings.distanceMeters, 20);
    expect(controller.state.alertSettings.autoApprovePhotos, isTrue);

    await controller.saveSafeZone(
      SafeZone(
        id: '',
        name: '통합테스트-$uniqueSuffix',
        address: '서울시 테스트구 통합로 1',
        radiusMeters: 90,
      ),
    );
    expect(
      controller.state.safeZones.any((zone) => zone.name == '통합테스트-$uniqueSuffix'),
      isTrue,
    );

    await controller.updateReward(
      '32222222-2222-2222-2222-222222222222',
      88888,
    );
    expect(
      controller.state.lostItems
          .firstWhere((item) => item.id == '32222222-2222-2222-2222-222222222222')
          .reward,
      88888,
    );

    final newThreadId = await controller.openOrCreateChatForItem(
      '34444444-4444-4444-4444-444444444444',
    );
    expect(newThreadId, isNotEmpty);

    await controller.sendMessage(
      '42222222-2222-2222-2222-222222222222',
      '플러터 실연동 메시지 $uniqueSuffix',
    );
    expect(
      controller.state.chatThreads
          .firstWhere((thread) => thread.id == '42222222-2222-2222-2222-222222222222')
          .messages
          .any((message) => message.text == '플러터 실연동 메시지 $uniqueSuffix'),
      isTrue,
    );

    await controller.requestPhotoApproval('42222222-2222-2222-2222-222222222222');
    await controller.approvePhoto('42222222-2222-2222-2222-222222222222');
    expect(
      controller.state.chatThreads
          .firstWhere((thread) => thread.id == '42222222-2222-2222-2222-222222222222')
          .photoStatus,
      PhotoAccessStatus.approved,
    );

    await controller.submitReport(
      threadId: '42222222-2222-2222-2222-222222222222',
      reason: '플러터 실연동 신고 $uniqueSuffix',
    );
    expect(
      controller.state.reports.any((report) => report.reason == '플러터 실연동 신고 $uniqueSuffix'),
      isTrue,
    );
  });
}
