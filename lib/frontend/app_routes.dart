import 'package:flutter/material.dart';

import 'pages/chat/chat_detail_page.dart';
import 'pages/discovery/discovery_page.dart';
import 'pages/join/join_page.dart';
import 'pages/login/login_page.dart';
import 'pages/menu/menu_page.dart';
import 'pages/shell/shell_page.dart';
import 'pages/welcome/welcome_page.dart';

/// 앱 안의 화면 이동 경로를 한곳에 모아둔 파일이다.
abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const join = '/join';
  static const shell = '/shell';
  static const sideMenu = '/menu';
  static const chatDetail = '/chat-detail';
  static const discovery = '/discovery';
}

abstract final class AppRouteFactory {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _page(settings: settings, child: const WelcomePage());
      case AppRoutes.login:
        return _page(settings: settings, child: const LoginPage());
      case AppRoutes.join:
        return _page(settings: settings, child: const JoinPage());
      case AppRoutes.shell:
        return _page(settings: settings, child: const AppShellPage());
      case AppRoutes.sideMenu:
        return PageRouteBuilder<void>(
          settings: settings,
          opaque: false,
          barrierColor: Colors.black45,
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MenuPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(-0.15, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      case AppRoutes.chatDetail:
        return _page(
          settings: settings,
          child: ChatDetailPage(threadId: settings.arguments! as String),
        );
      case AppRoutes.discovery:
        return _page(settings: settings, child: const DiscoveryPage());
      default:
        return _page(
          settings: settings,
          child: const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다.'))),
        );
    }
  }

  static MaterialPageRoute<void> _page({
    required RouteSettings settings,
    required Widget child,
  }) {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => child);
  }
}
