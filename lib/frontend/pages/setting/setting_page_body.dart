import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/setting_tile.dart';

import 'setting_page_handler.dart';

class SettingPageBody extends StatelessWidget {
  const SettingPageBody({
    required this.state,
    required this.handler,
    super.key,
  });

  final AppState state;
  final SettingPageHandler handler;

  @override
  Widget build(BuildContext context) {
    final settings = state.alertSettings;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          const Text('설정', style: AppTextStyles.headline),
          const SizedBox(height: 24),
          _SettingSection(
            title: '등록된 BLE 기기',
            child: Column(
              children: [
                for (final device in state.myDevices) ...[
                  _BleDeviceRow(
                    device: device,
                    onEdit: () => handler.openBleEditor(device: device),
                    onTest: () => handler.testBleDevice(device),
                  ),
                  const Divider(indent: 66),
                ],
                SettingTile(
                  icon: Icons.add_rounded,
                  title: '새 BLE 기기 추가',
                  onTap: handler.openBleEditor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingSection(
            title: '알림 설정',
            child: Column(
              children: [
                SettingTile(
                  icon: Icons.near_me_outlined,
                  title: '거리 기준 알림',
                  subtitle: '${settings.distanceMeters}m 이상 멀어지면 알림',
                  trailingText: '${settings.distanceMeters}m',
                  onTap: () => handler.pickNumber(
                    title: '거리 기준 선택',
                    values: const [5, 10, 20, 30],
                    currentValue: settings.distanceMeters,
                    onSelected: (value) => handler.updateAlertSettings(
                      settings.copyWith(distanceMeters: value),
                    ),
                    suffix: 'm',
                  ),
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.timer_outlined,
                  title: '시간 기준 알림',
                  subtitle: '${settings.disconnectMinutes}분 이상 끊기면 알림',
                  trailingText: '${settings.disconnectMinutes}분',
                  onTap: () => handler.pickNumber(
                    title: '시간 기준 선택',
                    values: const [1, 3, 5, 10],
                    currentValue: settings.disconnectMinutes,
                    onSelected: (value) => handler.updateAlertSettings(
                      settings.copyWith(disconnectMinutes: value),
                    ),
                    suffix: '분',
                  ),
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.vibration_outlined,
                  title: '진동 알림',
                  toggleValue: settings.vibrationEnabled,
                  onToggle: (value) => handler.updateAlertSettings(
                    settings.copyWith(vibrationEnabled: value),
                  ),
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.notifications_active_outlined,
                  title: '소리 알림',
                  toggleValue: settings.soundEnabled,
                  onToggle: (value) => handler.updateAlertSettings(
                    settings.copyWith(soundEnabled: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingSection(
            title: '안전지대 설정',
            child: Column(
              children: [
                for (final zone in state.safeZones) ...[
                  SettingTile(
                    icon: zone.name == '집' ? Icons.home_outlined : Icons.business_center_outlined,
                    title: zone.name,
                    subtitle: '${zone.address} · 반경 ${zone.radiusMeters}m',
                    onTap: () => handler.openSafeZoneEditor(zone: zone),
                  ),
                  const Divider(indent: 66),
                ],
                SettingTile(
                  icon: Icons.add_location_alt_outlined,
                  title: '안심 구역 추가',
                  onTap: handler.openSafeZoneEditor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingSection(
            title: '보안 및 프로필',
            child: Column(
              children: [
                SettingTile(
                  icon: Icons.person_outline_rounded,
                  title: '이름 등록',
                  subtitle: state.userProfile.name,
                  onTap: handler.openProfileEditor,
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.image_outlined,
                  title: '사진 등록',
                  subtitle: '대표 이미지 및 공개 상태 관리',
                  onTap: handler.openProfileEditor,
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.lock_outline_rounded,
                  title: '기본 사진 잠금',
                  toggleValue: settings.keepPhotoPrivateByDefault,
                  onToggle: (value) => handler.updateAlertSettings(
                    settings.copyWith(keepPhotoPrivateByDefault: value),
                  ),
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.verified_user_outlined,
                  title: '사진 자동 승인',
                  subtitle: '요청 도착 시 즉시 승인 처리',
                  toggleValue: settings.autoApprovePhotos,
                  onToggle: (value) => handler.updateAlertSettings(
                    settings.copyWith(autoApprovePhotos: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingSection(
            title: '기타',
            child: Column(
              children: [
                SettingTile(
                  icon: Icons.notifications_outlined,
                  title: '알림 내역',
                  onTap: handler.openNotifications,
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.flag_outlined,
                  title: '신고 내역',
                  onTap: handler.openReports,
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.help_outline_rounded,
                  title: '도움말 / FAQ',
                  onTap: handler.openHelp,
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.info_outline_rounded,
                  title: '앱 정보',
                  trailingText: 'v1.0.0',
                  onTap: handler.openAbout,
                ),
                const Divider(indent: 66),
                SettingTile(
                  icon: Icons.logout_rounded,
                  title: '로그아웃',
                  danger: true,
                  onTap: handler.logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BleDeviceRow extends StatelessWidget {
  const _BleDeviceRow({
    required this.device,
    required this.onEdit,
    required this.onTest,
  });

  final BleDevice device;
  final VoidCallback onEdit;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
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
              child: const Icon(Icons.bluetooth_rounded, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('BLE 코드: ${device.bleCode}', style: AppTextStyles.caption),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onTest,
              child: const Text('테스트'),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.overline,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ],
    );
  }
}
