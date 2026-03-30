import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    super.key,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.type != ChatMessageType.text) {
      final isApproved = message.type == ChatMessageType.photoApproved;
      final isReport = message.type == ChatMessageType.report;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isApproved
                    ? AppColors.greenBg
                    : isReport
                        ? AppColors.redBg
                        : AppColors.yellowBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isApproved
                        ? Icons.check_circle_outline_rounded
                        : isReport
                            ? Icons.flag_outlined
                            : Icons.hourglass_top_rounded,
                    size: 16,
                    color: isApproved
                        ? AppColors.green
                        : isReport
                            ? AppColors.red
                            : AppColors.yellow,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      message.text,
                      style: AppTextStyles.caption.copyWith(
                        color: isApproved
                            ? AppColors.green
                            : isReport
                                ? AppColors.red
                                : AppColors.yellow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(message.timeLabel, style: AppTextStyles.caption),
          ],
        ),
      );
    }

    final isMe = message.sender == ChatSender.me;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? const Radius.circular(6) : null,
            bottomLeft: !isMe ? const Radius.circular(6) : null,
          ),
          boxShadow: isMe
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: AppTextStyles.body.copyWith(
                color: isMe ? Colors.white : AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.timeLabel,
              style: AppTextStyles.caption.copyWith(
                color: isMe ? Colors.white70 : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
