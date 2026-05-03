import 'package:flutter_test/flutter_test.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/sources/app_state_json_mapper.dart';

void main() {
  test('alertSettings mapTheme가 없으면 기본값 dark를 사용한다', () {
    final state = AppStateJsonMapper.fromBootstrapJson({
      'userProfile': {
        'id': 'u1',
        'name': '테스트',
        'email': 'tester@example.com',
        'loginId': 'tester@example.com',
        'initials': '테',
        'photoAssetPath': '',
        'publicName': '테**',
      },
      'myDevices': const [],
      'lostItems': const [],
      'chatThreads': const [],
      'safeZones': const [],
      'alertSettings': {
        'distanceMeters': 10,
        'disconnectMinutes': 5,
        'vibrationEnabled': true,
        'soundEnabled': true,
        'autoApprovePhotos': false,
        'keepPhotoPrivateByDefault': true,
        'defaultReward': 30000,
      },
      'notifications': const [],
      'reports': const [],
    });

    expect(state.alertSettings.mapTheme, MapThemeMode.dark);
  });
}
