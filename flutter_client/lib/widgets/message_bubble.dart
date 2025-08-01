import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = message.username == '我';
    final isSystemMessage = message.isSystemMessage;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: isSystemMessage
            ? Alignment.center
            : (isOwnMessage ? Alignment.centerRight : Alignment.centerLeft),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSystemMessage ? 16.0 : 12.0,
            vertical: isSystemMessage ? 8.0 : 8.0,
          ),
          decoration: BoxDecoration(
            color: _getBubbleColor(context, isOwnMessage, isSystemMessage),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: isSystemMessage
                ? CrossAxisAlignment.center
                : (isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start),
            children: [
              if (!isSystemMessage && !isOwnMessage)
                Text(
                  message.username,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              if (message.isPrivateMessage && !isSystemMessage)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '私聊',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              Text(
                message.content,
                style: TextStyle(
                  color: _getTextColor(context, isOwnMessage, isSystemMessage),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message.formattedTime,
                style: TextStyle(
                  fontSize: 10,
                  color: _getTextColor(context, isOwnMessage, isSystemMessage)
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBubbleColor(BuildContext context, bool isOwnMessage, bool isSystemMessage) {
    if (isSystemMessage) {
      return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    }
    return isOwnMessage
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceVariant;
  }

  Color _getTextColor(BuildContext context, bool isOwnMessage, bool isSystemMessage) {
    if (isSystemMessage) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return isOwnMessage
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;
  }
}