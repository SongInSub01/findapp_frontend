import 'package:flutter/material.dart';

import 'package:my_flutter_starter/core/ble/ble_background_service.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'common/theme/app_theme.dart';
import 'frontend_scope.dart';
import 'pages/login/login_page.dart';
import 'pages/shell/shell_page.dart';

/// 앱 루트 위젯이다. 로그인 상태에 따라 첫 화면을 고르고,
/// 앱 생명주기를 감지해 백그라운드 BLE 서비스를 시작/중단한다.
class FindApp extends StatefulWidget {
  const FindApp({super.key});

  @override
  State<FindApp> createState() => _FindAppState();
}

class _FindAppState extends State<FindApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BleBackgroundService.instance.stopBackground();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // 앱이 백그라운드로 내려감 → 포그라운드 서비스 시작
        BleBackgroundService.instance.startBackground();
      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 복귀 → 서비스 종료 (지도 탭이 다시 스캔을 담당)
        BleBackgroundService.instance.stopBackground();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '찾아줘',
      theme: AppTheme.light(),
      home: controller.isAuthenticated ? const AppShellPage() : const LoginPage(),
      onGenerateRoute: AppRouteFactory.generate,
    );
  }
}
