import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'app/state/app_controller.dart';
import 'core/config/kakao_map_config.dart';
import 'frontend/find_app.dart';
import 'frontend/frontend_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 지도 키가 없어도 앱은 열리게 두고, 지도 화면에서 대체 UI를 보여준다.
  if (KakaoMapConfig.hasJavaScriptKey) {
    AuthRepository.initialize(appKey: KakaoMapConfig.javascriptKey);
  }

  // 기존 앱 로직 실행
  final controller = await AppController.create();
  await controller.bootstrap();

  runApp(AppScope(controller: controller, child: const FindApp()));
}
