import 'package:flutter/material.dart';

import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/secure_photo_thumbnail.dart';
import 'package:my_flutter_starter/frontend/common/widgets/status_badge.dart';

import 'chat_detail_handler.dart';
import 'chat_message_bubble.dart';

class ChatDetailBody extends StatelessWidget {
  const ChatDetailBody({
    required this.state,
    required this.threadId,
    required this.messageController,
    required this.isSendingMessage,
    required this.handler,
    super.key,
  });

  final AppState state;
  final String threadId;
  final TextEditingController messageController;
  final bool isSendingMessage;
  final ChatDetailHandler handler;

  @override
  Widget build(BuildContext context) {
    final threadCandidates = state.chatThreads
        .where((item) => item.id == threadId)
        .toList();
    if (threadCandidates.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 44,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text('채팅방을 찾지 못했습니다.', style: AppTextStyles.subtitle),
                  const SizedBox(height: 6),
                  Text(
                    '대화방이 삭제되었거나 아직 생성되지 않았습니다.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: handler.close,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('채팅 목록으로'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final thread = threadCandidates.first;
    final itemCandidates = state.lostItems
        .where((entry) => entry.id == thread.itemId)
        .toList();
    final item = itemCandidates.isEmpty ? null : itemCandidates.first;
    final canApprove = thread.photoStatus == PhotoAccessStatus.pending;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: handler.close,
                    icon: const Icon(Icons.chevron_left_rounded, size: 30),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(thread.itemTitle, style: AppTextStyles.subtitle),
                        Text(thread.otherUser, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => handler.showActions(thread),
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  SecurePhotoThumbnail(
                    photoStatus: thread.photoStatus,
                    assetPath: item?.photoAssetPath,
                    size: 64,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusBadge(status: thread.itemStatus, small: true),
                        if (thread.reward != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            '사례금 ${Formatters.money(thread.reward!)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          thread.photoStatus == PhotoAccessStatus.approved
                              ? '사진은 지금 바로 확인할 수 있습니다.'
                              : thread.photoStatus == PhotoAccessStatus.pending
                              ? '사진 승인 대기 중입니다.'
                              : '사진은 잠금 상태입니다.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (thread.photoStatus == PhotoAccessStatus.locked)
                        TextButton(
                          onPressed: () => handler.requestPhoto(),
                          child: const Text('사진 요청'),
                        ),
                      if (canApprove)
                        TextButton(
                          onPressed: () => handler.approvePhoto(),
                          child: const Text('승인 상태 확인'),
                        ),
                      if (thread.photoStatus == PhotoAccessStatus.approved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '사진 승인됨',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: thread.messages.length,
                itemBuilder: (context, index) {
                  final message = thread.messages[index];
                  return ChatMessageBubble(message: message);
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: '메시지를 입력하세요...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: isSendingMessage
                          ? null
                          : () => handler.sendMessage(),
                      icon: isSendingMessage
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
