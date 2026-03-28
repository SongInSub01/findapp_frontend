import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'common/theme/app_theme.dart';
import 'frontend_scope.dart';
import 'pages/login/login_page.dart';
import 'pages/shell/shell_page.dart';

/// 앱 루트 위젯이다. 로그인 상태에 따라 첫 화면을 고른다.
class FindApp extends StatelessWidget {
  const FindApp({super.key});

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
