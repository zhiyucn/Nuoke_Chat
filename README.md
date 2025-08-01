# Nuoke Chat
使用JavaScript编写的聊天系统，现在包含Flutter跨平台客户端

## 项目结构

- **server.js** - Node.js聊天服务器
- **client.js** - 原始Node.js命令行客户端
- **flutter_client/** - Flutter跨平台GUI客户端

## 运行方式

### 1. 启动服务器
```bash
node server.js
```

### 2. 选择客户端

#### 原始命令行客户端
```bash
node client.js [host] [port]
```

#### Flutter跨平台客户端
```bash
cd flutter_client
flutter run -d [platform]
```

### Flutter客户端支持平台
- ✅ Windows
- ✅ macOS  
- ✅ Linux
- ✅ Android
- ✅ iOS

警告：该项目如果需要编译请使用Node SEA编译