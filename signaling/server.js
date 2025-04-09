const express = require('express');
const app = express();
const http = require('http').Server(app);
const io = require('socket.io')(http);

var map = {}
// 监听客户端连接事件
io.on('connection', (socket) => {
    console.log('A user connected');

    // 监听客户端发送的 sdpMessage 事件
    socket.on('sdpMessage', (message) => {
        // 将消息广播给其他客户端
        socket.broadcast.emit('sdpMessage', message);
    });

    // 监听客户端断开连接事件
    socket.on('disconnect', () => {
        console.log('A user disconnected');
    });
        // 监听客户端断开连接事件
    socket.on('answer', (msg) => {
        console.log('A user answer', msg);
        // 给发送 answer 消息的客户端回一个消息
        socket.emit('offer', '收到你的 answer 消息，这是服务器的回复');
    });

});

const port = 3000;
http.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
