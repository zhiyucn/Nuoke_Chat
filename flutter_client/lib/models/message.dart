import 'package:intl/intl.dart';

enum MessageType {
  text,
  system,
  private,
}

class Message {
  final String username;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? target;

  Message({
    required this.username,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.target,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      username: json['username'] ?? '未知用户',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: _parseMessageType(json['type'] ?? 'text'),
      target: json['target'],
    );
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'system':
        return MessageType.system;
      case 'private':
        return MessageType.private;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'target': target,
    };
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(timestamp);
  }

  bool get isOwnMessage => username == '我';
  bool get isSystemMessage => type == MessageType.system;
  bool get isPrivateMessage => type == MessageType.private;
}