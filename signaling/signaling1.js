const express = require('express');
const app = express();
const http = require('http').Server(app);
const io = require('socket.io')(http);

// 存储客户端标识符和 socket 的映射
let sockMap = {};
let roomMap = {};

// 监听客户端连接事件
io.on('connection', (socket) => {
    console.log('A user connected');

    // 监听客户端断开连接事件
    socket.on('disconnect', () => {
        console.log('A user disconnected');
        // 清理已断开的客户端
        for (let sockId in sockMap) {
            if (sockMap[sockId] === socket) {
                delete sockMap[sockId];
                console.log(`Client ${sockId} removed`);
                break;
            }
        }
    });

    // 监听客户端发送的 join 事件，用于标识客户端身份
    socket.on('joinRoom', (message) => {
        const roomId = message["roomId"];
        // 判断 roomMap 中是否存在 roomId
        if ((roomId in roomMap) === false) {
            roomMap[roomId] = message
        } else {
            roomMap[roomId] = message
        }

        const sockId = message["clientId"];
        sockMap[sockId] = socket;
        console.log(`Client ${message} joined`);
    });

    // 监听客户端发送的 leave 事件，用于标识客户端身份
    socket.on('leaveRoom', (message) => {
        const roomId = message["roomId"];
        // 判断 roomMap 中是否存在 roomId
        if (roomId in roomMap) {
            delete roomMap[roomId];
        }
        const sockId = message["clientId"];
        if (sockId in sockMap) {
            delete sockMap[sockId];
        }
        console.log(`Client ${message} joined`);
    });
    
    // 监听客户端发送的 sdpMessage 事件
    socket.on('sdpMessage', (message) => {
        console.log('Received sdpMessage:', message);
        // 转发消息到指定客户端
        let targets = message["targets"];
        let type = message["type"];
        targets.forEach((targetId) => {
            if (sockMap[targetId]) {
                if (type === "offer") {
                    sockMap[targetId].emit('onOffer', message.sdp);
                } else if (type === "answer") {
                    sockMap[targetId].emit('onAnswer', message.sdp);
                }
            } else {
                console.log(`Client ${targetId} not found`);
            }
        });
    });

    // 监听客户端发送的 sdpMessage 事件
    socket.on('candidateMessage', (message) => {
        console.log('Received candidateMessage:', message);

        // 转发消息到指定客户端
        message["targets"].forEach((targetId) => {
            if (sockMap[targetId]) {
                sockMap[targetId].emit('onCandidate', message.data);
            } else {
                console.log(`Client ${targetId} not found`);
            }
        });
    });
    
});

const port = 3000;
http.listen(port, () => {
    console.log(`Server running on port ${port}`);
});