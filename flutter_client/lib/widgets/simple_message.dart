import 'package:flutter/material.dart';
import '../models/message.dart';

class SimpleMessage extends StatelessWidget {
  final Message message;

  const SimpleMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSystemMessage = message.isSystemMessage;
    final isPrivateMessage = message.isPrivateMessage;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSystemMessage)
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  _getMessageHeader(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getHeaderColor(context, isSystemMessage, isPrivateMessage),
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: _getContentColor(context, isSystemMessage),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              message.formattedTime,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMessageHeader() {
    if (message.isPrivateMessage) {
      return '[私聊] ${message.username}';
    }
    return message.username;
  }

  Color _getHeaderColor(BuildContext context, bool isSystemMessage, bool isPrivateMessage) {
    if (isSystemMessage) {
      return Theme.of(context).colorScheme.secondary;
    }
    if (isPrivateMessage) {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.primary;
  }

  Color _getContentColor(BuildContext context, bool isSystemMessage) {
    return isSystemMessage 
        ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
        : Theme.of(context).colorScheme.onSurface;
  }
}