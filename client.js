const net = require('net');
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const colors = require('colors');

class ChatClient {
    constructor() {
        this.client = new net.Socket();
        this.rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
        this.isConnected = false;
        this.username = '';
        this.config = this.loadConfig();
    }

    loadConfig() {
        try {
            const configPath = path.join(__dirname, 'config.json');
            const configData = fs.readFileSync(configPath, 'utf8');
            return JSON.parse(configData);
        } catch (error) {
            return {
                server: { port: 8888, host: 'localhost' },
                chat: { groupName: 'Nuoke聊天群' }
            };
        }
    }

    connect(host = null, port = null) {
        const configHost = host || this.config.server.host || 'localhost';
        const configPort = port || this.config.server.port || 8888;
        console.log('正在连接到聊天服务器...'.cyan);
        
        this.client.connect(configPort, configHost, () => {
            console.log('已连接到聊天服务器！'.green);
            this.isConnected = true;
        });

        this.client.on('data', (data) => {
            const message = data.toString();
            
            // 显示接收到的消息
            if (message.includes('[私聊]')) {
                console.log(message.magenta);
            } else if (message.includes('加入了')) {
                console.log(message.green);
            } else if (message.includes('离开了')) {
                console.log(message.red);
            } else if (message.includes('在线用户')) {
                console.log(message.yellow);
            } else if (message.includes('->')) {
                console.log(message.cyan);
            } else {
                console.log(message);
            }
        });

        this.client.on('close', () => {
            console.log('与服务器的连接已断开'.red);
            this.isConnected = false;
            this.rl.close();
            process.exit(0);
        });

        this.client.on('error', (err) => {
            console.error(`连接错误: ${err.message}`.red);
            this.rl.close();
            process.exit(1);
        });

        // 设置输入处理
        this.setupInputHandler();
    }

    setupInputHandler() {
        this.rl.on('line', (input) => {
            if (!this.isConnected) {
                console.log('尚未连接到服务器'.red);
                return;
            }

            const trimmed = input.trim();
            if (trimmed) {
                this.client.write(trimmed);
            }
        });

        // 处理 Ctrl+C
        this.rl.on('SIGINT', () => {
            console.log('\n正在断开连接...'.yellow);
            if (this.isConnected) {
                this.client.write('/quit');
                this.client.end();
            }
            this.rl.close();
            process.exit(0);
        });
    }
}

// 启动客户端
const args = process.argv.slice(2);
const host = args[0] || 'localhost';
const port = args[1] ? parseInt(args[1]) : 8888;

const client = new ChatClient();
client.connect(host, port);

// 显示客户端使用说明
console.log('Nuoke TCP聊天客户端'.cyan.bold);
console.log('==================='.cyan);
console.log('使用方法:');
console.log('  node client.js [host] [port]');
console.log('  默认连接: localhost:8888');
console.log('');
console.log('连接后输入用户名即可开始聊天！');
console.log('');