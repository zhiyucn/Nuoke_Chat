import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/user.dart';

class ChatService extends ChangeNotifier {
  Socket? _socket;
  String? username;
  bool isConnected = false;
  List<Message> messages = [];
  List<User> onlineUsers = [];
  String currentChatMode = 'group'; // 'group' or username for private
  String? privateChatTarget;
  String serverStatus = '未连接';
  bool _isLoggedIn = false;

  // 连接服务器
  Future<void> connect(String host, int port, String username, String password) async {
    this.username = username;
    
    try {
      serverStatus = '连接中...';
      notifyListeners();

      _socket = await Socket.connect(host, port);
      isConnected = true;
      serverStatus = '已连接';
      notifyListeners();

      // 发送用户名和密码进行登录
      _socket!.writeln(username);
      _socket!.writeln(password);
      // 发出日志
      print('ZY(-v-) 登录消息: $username');

      // 监听服务器消息
      _socket!.listen(
        (data) {
          final message = utf8.decode(data).trim();
          _handleServerMessage(message);
        },
        onError: (error) {
          serverStatus = '连接错误: $error';
          isConnected = false;
          notifyListeners();
        },
        onDone: () {
          serverStatus = '已断开';
          isConnected = false;
          _isLoggedIn = false;
          notifyListeners();
        },
      );

    } catch (e) {
      serverStatus = '连接失败: $e';
      isConnected = false;
      notifyListeners();
    }
  }

  void _handleServerMessage(String message) {
    if (message.isEmpty) return;

    // 处理不同类型的服务器消息
    if (message.contains('加入聊天室')) {
      // 用户加入消息
      final username = message.replaceAll(' 加入了聊天室！', '');
      onlineUsers.add(User(username: username));
      messages.add(Message(
            username: '系统',
            content: message,
            timestamp: DateTime.now(),
            type: MessageType.system,
          ));
    } else if (message.contains('离开了聊天室')) {
      // 用户离开消息
      final username = message.replaceAll(' 离开了聊天室', '').replaceAll('！', '');
      onlineUsers.removeWhere((user) => user.username == username);
      messages.add(Message(
        username: '系统',
        content: message,
        timestamp: DateTime.now(),
        type: MessageType.system,
      ));
    } else if (message.startsWith('[') && message.contains(']:')) {
      // 普通聊天消息格式: [时间] 用户名: 消息内容
      final parts = message.split(']: ');
      if (parts.length >= 2) {
        final timePart = parts[0];
        final contentPart = parts[1];
        
        if (contentPart.contains('->')) {
          // 私聊消息格式: [时间] [私聊] 发送者 -> 接收者: 消息
          final privateParts = contentPart.split(': ');
          if (privateParts.length >= 2) {
            final senderInfo = privateParts[0];
            final messageContent = privateParts[1];
            final sender = senderInfo.split(' -> ')[0].replaceAll('[私聊] ', '');
            
            messages.add(Message(
            username: sender,
            content: messageContent,
            timestamp: DateTime.now(),
            type: MessageType.private,
          ));
          }
        } else {
          // 群聊消息
          final username = contentPart.split(': ')[0];
          final content = contentPart.split(': ').sublist(1).join(': ');
          
          messages.add(Message(
            username: username,
            content: content,
            timestamp: DateTime.now(),
            type: MessageType.text,
          ));
        }
      }
    } else if (message.startsWith('在线用户')) {
      // 在线用户列表
      _updateOnlineUsers(message);
    } else if (message.startsWith('欢迎来到')) {
      // 欢迎消息，忽略
      return;
    } else if (message.contains('输入 /help 查看可用命令')) {
      // 登录成功后的提示，标记为已登录
      _isLoggedIn = true;
      // 登录成功后自动获取在线用户列表
      getOnlineUsers();
      return;
    } else if (message.contains('密码错误') || message.contains('密码不正确')) {
      // 密码错误
      _isLoggedIn = false;
      messages.add(Message(
        username: '系统',
        content: message,
        timestamp: DateTime.now(),
        type: MessageType.system,
      ));
      // 延迟断开连接，让用户看到错误消息
      Future.delayed(const Duration(seconds: 2), () {
        disconnect();
      });
      return;
    } else if (message.contains('用户已离线') || message.contains('用户已下线') || message.contains('不存在')) {
      // 私聊目标用户已离线，自动返回群聊
      if (currentChatMode != 'group') {
        final targetUser = currentChatMode;
        messages.add(Message(
          username: '系统',
          content: '用户 $targetUser 已离线，已自动返回群聊',
          timestamp: DateTime.now(),
          type: MessageType.system,
        ));
        switchToGroupChat();
      } else {
        messages.add(Message(
          username: '系统',
          content: message,
          timestamp: DateTime.now(),
          type: MessageType.system,
        ));
      }
    } else {
      // 其他系统消息
      messages.add(Message(
        username: '系统',
        content: _removeAnsiCodes(message),
        timestamp: DateTime.now(),
        type: MessageType.system,
      ));
    }

    notifyListeners();
  }

  void _updateOnlineUsers(String message) {
    // 解析在线用户列表
    final match = RegExp(r'在线用户 \((\d+)\): (.+)').firstMatch(message);
    if (match != null) {
      final count = int.parse(match.group(1)!);
      final usersStr = match.group(2)!;
      
      onlineUsers.clear();
      if (usersStr.isNotEmpty && usersStr != '无') {
        final usernames = usersStr.split(', ');
        for (final username in usernames) {
          onlineUsers.add(User(username: username));
        }
      }
    }
  }

  // 发送消息
  void sendMessage(String content) {
    if (_socket == null || !isConnected || !_isLoggedIn) return;

    if (currentChatMode == 'group') {
      // 群聊消息
      // 发出日志
      print('ZY(-v-) 群聊消息: $content');
      _socket!.writeln(content);
    } else {
      // 私聊消息 - 直接发送消息内容，不再发送/w命令前缀
      // 因为已经在switchToPrivateChat时发送了/w命令建立会话
      print('ZY(-v-) 私聊消息: $currentChatMode $content');
      _socket!.writeln(content);
    }
  }

  // 切换到私聊模式
  void switchToPrivateChat(String targetUsername) {
    currentChatMode = targetUsername;
    privateChatTarget = targetUsername;
    // 发送/w命令建立私聊会话
    if (_socket != null && isConnected && _isLoggedIn) {
      _socket!.writeln('/w $targetUsername');
    }
    notifyListeners();
  }

  // 切换回群聊模式
  void switchToGroupChat() {
    currentChatMode = 'group';
    privateChatTarget = null;
    notifyListeners();
  }

  // 断开连接
  void disconnect() {
    if (_socket != null) {
      _socket!.writeln('/quit');
      _socket!.destroy();
      _socket = null;
    }
    isConnected = false;
    _isLoggedIn = false;
    username = null;
    messages.clear();
    onlineUsers.clear();
    serverStatus = '未连接';
    notifyListeners();
  }

  // 获取在线用户
  void getOnlineUsers() {
    if (_socket != null && isConnected && _isLoggedIn) {
      _socket!.writeln('/users');
    }
  }

  // 移除ANSI颜色代码
  String _removeAnsiCodes(String text) {
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*[mK]'), '');
  }
}