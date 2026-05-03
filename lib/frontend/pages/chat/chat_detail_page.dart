import 'dart:async';

import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'chat_detail_body.dart';
import 'chat_detail_handler.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({required this.threadId, super.key});

  final String threadId;

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _didMarkRead = false;
  bool _isSendingMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didMarkRead) {
      return;
    }
    final controller = AppScope.controllerOf(context);
    final threadExists = controller.state.chatThreads.any(
      (item) => item.id == widget.threadId,
    );
    if (!threadExists) {
      _didMarkRead = true;
      return;
    }
    _didMarkRead = true;
    unawaited(controller.markChatThreadRead(widget.threadId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;
    final handler = ChatDetailHandler(
      context: context,
      controller: controller,
      state: state,
      threadId: widget.threadId,
      messageController: _messageController,
      isSendingMessage: _isSendingMessage,
      onSendingMessageChanged: (value) {
        if (mounted) {
          setState(() => _isSendingMessage = value);
        }
      },
    );

    return ChatDetailBody(
      state: state,
      threadId: widget.threadId,
      messageController: _messageController,
      isSendingMessage: _isSendingMessage,
      handler: handler,
    );
  }
}
