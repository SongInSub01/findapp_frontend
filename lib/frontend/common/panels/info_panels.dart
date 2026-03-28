import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_helpers.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';

Future<void> showNotificationPanel(
  BuildContext context, {
  required AppController controller,
  required AppState state,
}) async {
  controller.markNotificationsRead();
  final updatedState = controller.state;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return AppPanelScaffold(
        title: '알림 내역',
        subtitle: 'BLE 경고, 사진 승인, 신고 처리 상태를 한 번에 확인합니다.',
        child: updatedState.notifications.isEmpty
            ? const PanelEmpty(
                icon: Icons.notifications_none_rounded,
                title: '도착한 알림이 없습니다',
                subtitle: 'BLE 거리 경고나 사진 승인 요청이 생기면 여기에 쌓입니다.',
              )
            : Column(
                children: [
                  for (final item in updatedState.notifications) ...[
                    PanelInfoCard(
                      icon: notificationIcon(item.type),
                      iconColor: notificationColor(item.type),
                      title: item.title,
                      body: item.body,
                      trailing: item.timeLabel,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
      );
    },
  );
}

Future<void> showReportPanel(
  BuildContext context, {
  required AppState state,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return AppPanelScaffold(
        title: '신고 내역',
        subtitle: '비매너 유저 신고 접수와 검토 상태를 확인합니다.',
        child: state.reports.isEmpty
            ? const PanelEmpty(
                icon: Icons.flag_outlined,
                title: '접수된 신고가 없습니다',
                subtitle: '채팅 상세에서 신고하면 이 목록에 저장됩니다.',
              )
            : Column(
                children: [
                  for (final report in state.reports) ...[
                    PanelInfoCard(
                      icon: Icons.flag_outlined,
                      iconColor: AppColors.red,
                      title: report.targetTitle,
                      body: '${report.reason}\n상태: ${report.statusLabel}',
                      trailing: report.createdAtLabel,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
      );
    },
  );
}

Future<void> showHelpPanel(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return const AppPanelScaffold(
        title: '도움말 / FAQ',
        subtitle: '찾아줘 앱의 핵심 흐름과 보안 정책을 빠르게 확인합니다.',
        child: Column(
          children: [
            FaqTile(
              question: '사진이 바로 보이지 않는 이유는 무엇인가요?',
              answer: '분실물 사진은 기본 잠금 상태이며, 주인이 승인해야만 열람할 수 있습니다.',
            ),
            SizedBox(height: 10),
            FaqTile(
              question: 'BLE 알림이 울리지 않는 구역은 어떻게 설정하나요?',
              answer: '설정 화면의 안전지대 항목에서 집, 회사 같은 안심 구역을 등록하면 됩니다.',
            ),
            SizedBox(height: 10),
            FaqTile(
              question: '주변 사용자는 무엇을 볼 수 있나요?',
              answer: '분실물 사진은 보이지 않고, 근처에 있다는 알림과 기본 정보만 확인할 수 있습니다.',
            ),
            SizedBox(height: 10),
            FaqTile(
              question: '사례금은 어디서 수정하나요?',
              answer: '메인 화면의 사례금 등록 버튼과 설정의 등록 관리 흐름에서 수정할 수 있습니다.',
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showAppAboutDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('앱 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('찾아줘', style: AppTextStyles.subtitle.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text('BLE 기반 분실물 탐지, 사진 승인 보호, 연락/신고 흐름을 한 앱에서 관리합니다.'),
            const SizedBox(height: 12),
            Text('버전 1.0.0', style: AppTextStyles.caption),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}
