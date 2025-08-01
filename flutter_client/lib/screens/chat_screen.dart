import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service_tcp.dart';
import '../services/theme_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/user_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chatService.currentChatMode == 'group' 
                ? '群聊' 
                : '私聊: ${chatService.currentChatMode}'),
            Text(
              chatService.serverStatus,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const UserList(),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'theme',
                child: Text('切换主题'),
              ),
              const PopupMenuItem(
                value: 'disconnect',
                child: Text('断开连接'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'theme':
                  _showThemeDialog(context, themeService);
                  break;
                case 'disconnect':
                  _handleDisconnect(context);
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 聊天模式切换
          if (chatService.currentChatMode != 'group')
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 16),
                  const SizedBox(width: 8),
                  Text('正在与 ${chatService.currentChatMode} 私聊'),
                  const Spacer(),
                  TextButton(
                    onPressed: chatService.switchToGroupChat,
                    child: const Text('返回群聊'),
                  ),
                ],
              ),
            ),
          
          // 消息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: chatService.messages.length,
              itemBuilder: (context, index) {
                final message = chatService.messages.reversed.toList()[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          
          // 输入框
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: chatService.currentChatMode == 'group' 
                          ? '发送群聊消息...'
                          : '发送给 ${chatService.currentChatMode}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatService = Provider.of<ChatService>(context, listen: false);
    chatService.sendMessage(message);
    _messageController.clear();

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showThemeDialog(BuildContext context, ThemeService themeService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('跟随系统'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeService.themeMode,
                onChanged: (value) {
                  themeService.toggleTheme(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('浅色模式'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeService.themeMode,
                onChanged: (value) {
                  themeService.toggleTheme(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('深色模式'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeService.themeMode,
                onChanged: (value) {
                  themeService.toggleTheme(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDisconnect(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('断开连接'),
        content: const Text('确定要断开与服务器的连接吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatService>(context, listen: false).disconnect();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}