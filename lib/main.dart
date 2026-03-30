import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; 

import 'app/state/app_controller.dart';
import 'frontend/find_app.dart';
import 'frontend/frontend_scope.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 자바스트립트 키
  AuthRepository.initialize(appKey: '67b7ec8b17ed6d1e7d6418b8fe391d44'); 

  // 기존 앱 로직 실행
  final controller = await AppController.create();
  await controller.bootstrap();

  runApp(
    AppScope(
      controller: controller,
      child: const FindApp(),
    ),
  );
}