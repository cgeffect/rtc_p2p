const express = require('express');
const app = express();
const http = require('http').Server(app);
const io = require('socket.io')(http);

/*
[
    {
        "roomId": "123456",
        "members": [
            {
                "sockId": "",
                "socket": object
            }
        ]
    }
]
*/
let rooms = [];
// 监听客户端连接事件
io.on('connection', (socket) => {
    console.log('A user connected');

    // 监听客户端断开连接事件
    socket.on('disconnect', () => {
        console.log('A user disconnected');

        // 移除成员
        rooms.forEach(room => {
            room.members = room.members.filter(member => member.sockId !== socket.id);
            console.log(`Room ${room.roomId} now has ${room.members.length} members`);

            // 如果房间为空，删除房间
            if (room.members.length === 0) {
                rooms = rooms.filter(r => r.roomId !== room.roomId);
                console.log(`Room ${room.roomId} has been deleted`);
            }
        });
    });

    socket.on('__join', (message) => {
        const roomId = message["roomId"];
        const sockId = message["sockId"];

        console.log(`User ${socket.id} joined room ${roomId}`);
        // 检查房间是否存在
        let room = rooms.find(r => r.roomId === roomId);

        if (!room) {
            // 如果房间不存在，创建新房间
            room = {
                roomId: roomId,
                members: []
            };
            rooms.push(room);
        } else {
            // 如果房间存在，检查是否已经加入
            const member = room.members.find(m => m.sockId === socket.id);
            if (member) {
                console.log(`User ${socket.id} already joined room ${roomId}`);
                console.log('You have already joined this room')
            }
        }

        // 添加成员到房间
        room.members.push({
            sockId: socket.id,
            socket: socket
        });

        console.log(`Room ${roomId} now has ${room.members.length} members`);

        // 发送房间成员列表给所有成员
        // room.members.forEach(member => {
        //     member.socket.emit('__roomMembers', room.members.map(m => m.sockId));
        // });
        // 发送房间信息给客户端
        socket.emit('__joined', {
            roomId: roomId,
            members: room.members.map(m => m.sockId)
        });

        // 发送房间成员列表给所有成员
        room.members.forEach(member => {
            member.socket.emit('__joined', {
                roomId: roomId,
                members: room.members.map(m => m.sockId)
            });
        })
        console.log(`Client ${message} joined`);
    });

    socket.on('__leave', (message) => {
        const roomId = message["roomId"];
        const sockId = message["sockId"];
    
        // 检查房间是否存在
        const room = rooms.find(r => r.roomId === roomId);
        if (!room) {
            console.log(`Room ${roomId} does not exist`);
            return;
        }
    
        // 检查成员是否存在
        const member = room.members.find(m => m.sockId === sockId);
        if (!member) {
            console.log(`User ${sockId} is not in room ${roomId}`);
            return;
        }
    
        // 移除成员
        room.members = room.members.filter(m => m.sockId !== sockId);
        console.log(`User ${sockId} left room ${roomId}`);
    
        // 发送房间成员列表给所有成员
        room.members.forEach(member => {
            member.socket.emit('__left', {
                roomId: roomId,
                members: room.members.map(m => m.sockId)
            });
        });
    
        // 如果房间为空，删除房间
        if (room.members.length === 0) {
            rooms = rooms.filter(r => r.roomId !== roomId);
            console.log(`Room ${roomId} has been deleted`);
        }
    
        // 发送 leave 事件给所有客户端，通知它们该客户端已离开
        io.emit('__left', message); // 发送给所有客户端，包括自己
    
        console.log(`Client ${message} left`);
    });

    // 监听客户端发送的 sdpMessage 事件
    socket.on('__ice_candidate', (message) => {
        console.log('Received candidateMessage:', message);

        const roomId = message["roomId"];
        const sockId = message["sockId"];

        // 检查房间是否存在
        const room = rooms.find(r => r.roomId === roomId);
        if (!room) {
            console.log(`Room ${roomId} does not exist`);
            return;
        }
        // 检查成员是否存在
        const member = room.members.find(m => m.sockId === sockId);
        if (!member) {
            console.log(`User ${sockId} is not in room ${roomId}`);
            return;
        }
        
        var sock = getSocket(sockId);
        // 发送 ice_candidate 事件给所有客户端，通知它们该客户端已离开
        room.members.forEach(member => {
            const data = JSON.stringify({
                "eventName": "_ice_candidate",
                "data": {
                    "id": data.id,
                    "label": data.label,
                    "sdpMLineIndex" :data.label,
                    "candidate": data.candidate,
                    "socketId": socket.id
                }
            })
            member.socket.emit('__ice_candidate', data);
        });
    });   

    socket.on('__offer', function (data, socket) {
        const roomId = message["roomId"];
        const sockId = message["sockId"];
        // 检查房间是否存在
        const room = rooms.find(r => r.roomId === roomId);
        if (!room) {
            console.log(`Room ${roomId} does not exist`);
            return;
        }
        // 检查成员是否存在
        const member = room.members.find(m => m.sockId === sockId);
        if (!member) {
            console.log(`User ${sockId} is not in room ${roomId}`);
            return;
        }

        // 发送 offer 事件给所有客户端，通知它们该客户端已离开
        room.members.forEach(member => {
            const data = JSON.stringify({
                "eventName": "_offer",
                "data": {
                    "sdp": data.sdp,
                    "socketId": socket.id
                }
            });

            member.socket.emit('__offer', data);
        });
    });

    socket.on('__answer', function (data, socket) {
        const roomId = message["roomId"];
        const sockId = message["sockId"];
        // 检查房间是否存在
        const room = rooms.find(r => r.roomId === roomId);
        if (!room) {
            console.log(`Room ${roomId} does not exist`);
            return;
        }
        // 检查成员是否存在
        const member = room.members.find(m => m.sockId === sockId);
        if (!member) {
            console.log(`User ${sockId} is not in room ${roomId}`);
            return;
        }

        // 发送 answer 事件给所有客户端，通知它们该客户端已离开
        room.members.forEach(member => {
            const data = JSON.stringify({
                "eventName": "_answer",
                "data": {
                    "sdp": data.sdp,
                    "socketId": socket.id
                }
            });
            member.socket.emit('__answer', data);
        })
    });

    // 发起邀请
    socket.on('__invite', function (data) {

    });
    // 回应数据
    socket.on('__ack', function (data) {

    });
    
});

function getSocket(socketId) {
    rooms.forEach((room) => {
        room.members.forEach((member) => {
            if (member.sockId === socketId) {
                return member.socket;
            }
        })
    })
    return null;
};

// 启动服务器
const port = 3000;
http.listen(port, () => {
    console.log(`Server running on port ${port}`);
});