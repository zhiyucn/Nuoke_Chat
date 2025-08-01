import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service_tcp.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 8),
              Text(
                '在线用户 (${chatService.onlineUsers.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => chatService.getOnlineUsers(),
                tooltip: '刷新用户列表',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: chatService.onlineUsers.length,
              itemBuilder: (context, index) {
                final user = chatService.onlineUsers[index];
                final isCurrentUser = user.username == chatService.username;
                
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username[0].toUpperCase()),
                  ),
                  title: Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: isCurrentUser ? const Text('(我自己)') : null,
                  trailing: isCurrentUser 
                      ? null 
                      : TextButton(
                          onPressed: () {
                            chatService.switchToPrivateChat(user.username);
                            Navigator.pop(context);
                          },
                          child: const Text('私聊'),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '点击用户开始私聊，点击右上角关闭返回',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}