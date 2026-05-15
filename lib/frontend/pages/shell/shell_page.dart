import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'package:my_flutter_starter/frontend/pages/chat/chat_page.dart';
import 'package:my_flutter_starter/frontend/pages/main/main_page.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_page.dart';

// 기존 SettingPage 대신 RewardPage 추가
import 'package:my_flutter_starter/frontend/pages/reward/reward_page.dart';

/// ROOT SHELL PAGE
/// 앱 전체 진입점
/// HOME / MAP / CHAT / REWARD 탭 구조 관리
class AppShellPage extends StatelessWidget {
  const AppShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);

    return _AppShellBody(
      controller: controller,
      state: controller.state,
    );
  }
}

class _AppShellBody extends StatelessWidget {
  const _AppShellBody({
    required this.controller,
    required this.state,
  });

  final AppController controller;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: state.currentTab.index,
        children: [
          /// HOME
          const MainPage(),

          /// MAP
          MapPage(
            isVisible: state.currentTab == AppTab.map,
          ),

          /// CHAT
          const ChatPage(),

          /// REWARD
          const RewardPage(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,

        indicatorColor: AppColors.primary.withValues(alpha: 0.12),

        selectedIndex: state.currentTab.index,

        onDestinationSelected: (index) {
          controller.switchTab(AppTab.values[index]);
        },

        destinations: const [
          /// HOME
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),

          /// MAP
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: '지도',
          ),

          /// CHAT
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '채팅',
          ),

          /// REWARD
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard),
            label: '리워드',
          ),
        ],
      ),
    );
  }
}