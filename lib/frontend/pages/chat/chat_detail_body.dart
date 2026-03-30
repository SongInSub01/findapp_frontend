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
    required this.handler,
    super.key,
  });

  final AppState state;
  final String threadId;
  final TextEditingController messageController;
  final ChatDetailHandler handler;

  @override
  Widget build(BuildContext context) {
    final thread = state.chatThreads.firstWhere((item) => item.id == threadId);
    final itemCandidates = state.lostItems.where((entry) => entry.id == thread.itemId);
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
                        Text(thread.itemTitle, style: AppTextStyles.subtitle),
                        const SizedBox(height: 4),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            if (thread.photoStatus != PhotoAccessStatus.approved)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: thread.photoStatus == PhotoAccessStatus.pending
                      ? AppColors.yellowBg
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      thread.photoStatus == PhotoAccessStatus.pending
                          ? Icons.hourglass_top_rounded
                          : Icons.lock_outline,
                      size: 16,
                      color: thread.photoStatus == PhotoAccessStatus.pending
                          ? AppColors.yellow
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        thread.photoStatus == PhotoAccessStatus.pending
                            ? '승인 대기 상태입니다. 주인이 허용하면 즉시 사진을 열람할 수 있습니다.'
                            : '사진 잠금 상태입니다. 먼저 메시지를 보낸 뒤 사진 요청을 진행해 주세요.',
                        style: AppTextStyles.caption.copyWith(
                          color: thread.photoStatus == PhotoAccessStatus.pending
                              ? AppColors.yellow
                              : AppColors.textSecondary,
                        ),
                      ),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: TextButton.icon(
                onPressed: () => handler.showReportDialog(thread.id),
                icon: const Icon(Icons.flag_outlined, size: 16),
                label: const Text('비매너 신고'),
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
                      onPressed: () => handler.sendMessage(),
                      icon: const Icon(Icons.send_rounded),
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
