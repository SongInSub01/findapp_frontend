import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';

class ChatDetailHandler {
  ChatDetailHandler({
    required this.context,
    required this.controller,
    required this.state,
    required this.threadId,
    required this.messageController,
  });

  final BuildContext context;
  final AppController controller;
  final AppState state;
  final String threadId;
  final TextEditingController messageController;

  void close() {
    Navigator.of(context).pop();
  }

  Future<void> requestPhoto() async {
    try {
      await controller.requestPhotoApproval(threadId);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> approvePhoto() async {
    try {
      await controller.approvePhoto(threadId);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) {
      return;
    }
    try {
      await controller.sendMessage(threadId, text);
      messageController.clear();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> showActions(ChatThread thread) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('채팅 옵션', style: AppTextStyles.title),
                const SizedBox(height: 12),
                AppSecondaryButton(
                  label: '사진 요청 재전송',
                  icon: Icons.image_search_outlined,
                  onPressed: () async {
                    try {
                      await controller.requestPhotoApproval(thread.id);
                      if (!sheetContext.mounted) {
                        return;
                      }
                      Navigator.of(sheetContext).pop();
                    } catch (error) {
                      if (!sheetContext.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                      );
                    }
                  },
                  expanded: true,
                ),
                const SizedBox(height: 10),
                AppSecondaryButton(
                  label: '비매너 유저 신고',
                  icon: Icons.flag_outlined,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    showReportDialog(thread.id);
                  },
                  expanded: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showReportDialog(String targetThreadId) async {
    String reason = '욕설 또는 비매너 응답';
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('신고하기'),
          content: DropdownButtonFormField<String>(
            initialValue: reason,
            items: const [
              DropdownMenuItem(value: '욕설 또는 비매너 응답', child: Text('욕설 또는 비매너 응답')),
              DropdownMenuItem(value: '허위 제보', child: Text('허위 제보')),
              DropdownMenuItem(value: '사진 승인 악용', child: Text('사진 승인 악용')),
            ],
            onChanged: (value) {
              if (value != null) {
                reason = value;
              }
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            FilledButton(
              onPressed: () async {
                try {
                  await controller.submitReport(threadId: targetThreadId, reason: reason);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                } catch (error) {
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                  );
                }
              },
              child: const Text('접수'),
            ),
          ],
        );
      },
    );
  }
}
