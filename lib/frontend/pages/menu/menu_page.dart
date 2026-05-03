import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/inline_feature_panels.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// MENU PAGE
/// 프로필, 통계, 보조 메뉴를 보여주는 좌측 사이드 메뉴 페이지다.
/// 메뉴에서 필요한 카드와 메뉴 액션을 이 파일 안에서 모두 정의한다.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    return _SideMenuBody(controller: controller, state: controller.state);
  }
}

class _SideMenuBody extends StatelessWidget {
  const _SideMenuBody({required this.controller, required this.state});

  final AppController controller;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final menuWidth = math.min(340.0, MediaQuery.sizeOf(context).width - 48);
    return Material(
      color: AppColors.overlay,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: menuWidth,
          height: double.infinity,
          color: AppColors.background,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('메뉴', style: AppTextStyles.title),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFFEFF6FF),
                          backgroundImage: AssetImage(
                            state.userProfile.photoAssetPath,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.userProfile.name,
                                style: AppTextStyles.subtitle,
                              ),
                              Text(
                                state.userProfile.email,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showProfileEditorPanel(
                              context,
                              controller: controller,
                              profile: state.userProfile,
                            );
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _StatCard(
                          value: '${state.myDevices.length}',
                          label: '등록 기기',
                        ),
                        _verticalDivider(),
                        _StatCard(
                          value: '${state.chatThreads.length}',
                          label: '채팅 중',
                        ),
                        _verticalDivider(),
                        _StatCard(
                          value:
                              '${state.myDevices.where((d) => d.status == ItemStatus.lost).length}',
                          label: '분실 중',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _MenuGroup(
                          title: '내 물건 관리',
                          children: [
                            _MenuTile(
                              icon: Icons.inventory_2_outlined,
                              title: '내 등록 물건 관리',
                              onTap: () {
                                Navigator.of(context).pop();
                                controller.switchTab(AppTab.main);
                              },
                            ),
                            _MenuTile(
                              icon: Icons.bluetooth_rounded,
                              title: 'BLE 기기 관리',
                              onTap: () {
                                Navigator.of(context).pop();
                                controller.switchTab(AppTab.setting);
                              },
                            ),
                            _MenuTile(
                              icon: Icons.add_location_alt_outlined,
                              title: '안심 구역 설정',
                              onTap: () {
                                Navigator.of(context).pop();
                                controller.switchTab(AppTab.setting);
                              },
                            ),
                            _MenuTile(
                              icon: Icons.manage_search_rounded,
                              title: '분실·습득 탐색',
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.discovery);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _MenuGroup(
                          title: '알림 및 기록',
                          children: [
                            _MenuTile(
                              icon: Icons.notifications_outlined,
                              title: '알림 내역',
                              badge: state.notifications
                                  .where((item) => !item.isRead)
                                  .length,
                              onTap: () {
                                showNotificationPanel(
                                  context,
                                  controller: controller,
                                  state: state,
                                );
                              },
                            ),
                            _MenuTile(
                              icon: Icons.flag_outlined,
                              title: '신고 내역',
                              onTap: () {
                                showReportPanel(context, state: state);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _MenuGroup(
                          title: '기타',
                          children: [
                            _MenuTile(
                              icon: Icons.help_outline_rounded,
                              title: '도움말 / FAQ',
                              onTap: () {
                                showHelpPanel(context);
                              },
                            ),
                            _MenuTile(
                              icon: Icons.info_outline_rounded,
                              title: '앱 정보',
                              onTap: () {
                                showAppAboutDialog(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await controller.signOut();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('로그아웃'),
                    style: FilledButton.styleFrom(
                      foregroundColor: AppColors.red,
                      backgroundColor: AppColors.redBg,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _verticalDivider() {
  return Container(width: 1, height: 36, color: AppColors.borderLight);
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: AppTextStyles.overline),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTextStyles.body)),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$badge',
                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                ),
              ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.title.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
