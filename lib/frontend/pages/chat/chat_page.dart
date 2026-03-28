import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/empty_state.dart';
import 'package:my_flutter_starter/frontend/common/widgets/inline_feature_panels.dart';
import 'package:my_flutter_starter/frontend/common/widgets/secure_photo_thumbnail.dart';
import 'package:my_flutter_starter/frontend/common/widgets/status_badge.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// CHAT PAGE
/// 진행 중인 분실물 관련 대화 목록을 보여주는 페이지다.
/// 각 대화의 상태, 사진 잠금 여부, unread 수, 상세 대화방 진입을 이 파일에서 처리한다.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    return _ChatBody(controller: controller, state: controller.state);
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.controller,
    required this.state,
  });

  final AppController controller;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Expanded(child: Text('채팅', style: AppTextStyles.headline)),
                IconButton(
                  onPressed: () => showNotificationPanel(
                    context,
                    controller: controller,
                    state: state,
                  ),
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '알림 → 메시지 전송 → 승인 대기 → 승인 후 사진 열람 순서가 유지됩니다',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.chatThreads.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: '진행 중인 채팅이 없습니다',
                    subtitle: '주변 분실물 카드에서 메시지를 보내면 채팅이 생성됩니다.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    itemBuilder: (context, index) {
                      final thread = state.chatThreads[index];
                      final linkedItem = state.lostItems.where((item) => item.id == thread.itemId);
                      final assetPath = linkedItem.isEmpty ? null : linkedItem.first.photoAssetPath;
                      return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.chatDetail,
                          arguments: thread.id,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SecurePhotoThumbnail(
                                photoStatus: thread.photoStatus,
                                assetPath: assetPath,
                                size: 62,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            thread.itemTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.subtitle,
                                          ),
                                        ),
                                        Text(thread.lastTime, style: AppTextStyles.caption),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        StatusBadge(status: thread.itemStatus, small: true),
                                        if (thread.reward != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            '사례금 ${Formatters.money(thread.reward!)}',
                                            style: AppTextStyles.caption.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            thread.lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.bodySecondary,
                                          ),
                                        ),
                                        if (thread.unread > 0)
                                          Container(
                                            margin: const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              '${thread.unread}',
                                              style: AppTextStyles.caption.copyWith(color: Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(indent: 76),
                    itemCount: state.chatThreads.length,
                  ),
          ),
        ],
      ),
    );
  }
}
