//
//  WebSocketManager.m
//  rtc_macos
//
//  Created by Jason on 2025/3/19.
//

#import "WebSocketManager.h"
#import <rtc_macos-Swift.h>

@interface WebSocketManager ()<PeerConnectionManagerDelegate, SignalClientDelegate>
@property (nonatomic, strong)PeerConnectionManager *peerConnectionManager;
@property (nonatomic, strong)SocketClient *mWebSocketClient;
@property (nonatomic, strong) void(^joinBlock)(NSString *roomId);
@end

@implementation WebSocketManager

- (instancetype)initWithPeer:(PeerConnectionManager *)peerConnectionManager {
    self = [super init];
    if (self) {
        // 初始化代码
        self.peerConnectionManager = peerConnectionManager;
    }
    return self;
}

- (void)connect:(NSString *)ws {
    
}

- (void)joinRoom:(nonnull NSString *)roomId handler:(void(^)(NSString *roomId))block {
    if (self.mWebSocketClient == nil) {
        self.mWebSocketClient = [[SocketClient alloc] initWithRoomId:roomId];
    }
    
    NSDictionary *dataMap = @{
        @"roomId": roomId
    };
    NSDictionary *map = @{
        @"eventName": @"__join",
        @"data": dataMap
    };
    NSLog(@"send--> %@", map.description);

    [self.mWebSocketClient joinRoomWithMap:map];
    self.joinBlock = block;
}

#pragma makr - handle开头的函数都是处理接收到数据
// 自己已经在房间，有人进来    通知你有人进来     实例控件   新建链接    做准备
- (void)handleRemoteInRoom:(NSDictionary *)map {
    NSLog(@"handleRemoteInRoom: %@", map);
    NSDictionary *data = [map objectForKey:@"data"];
    if (data != nil) {
        NSString *socketId = [data objectForKey:@"socketId"];
        [self.peerConnectionManager onRemoteJoinToRoom:socketId];
    }
}

// 处理Offer   后面进来的 人来  对方的sdp发送给你   真正开始做链接  相亲    ----   7天酒店
- (void)handleOffer:(NSDictionary *)map {
    NSLog(@"handleOffer: %@", map);
    NSDictionary *data = [map objectForKey:@"data"];
    if (data != nil) {
        NSDictionary *sdpDic = [data objectForKey:@"sdp"];
        NSString *socketId = [data objectForKey:@"socketId"];
        NSString *sdp = [sdpDic objectForKey:@"sdp"];

        RTCSessionDescription *session = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:sdp];
        [self.peerConnectionManager onReceiveOffer:session fromUserId:socketId];
    }
}
//    响应  基于他业务, 自己是被叫
- (void)hanleJoinRoom:(NSDictionary *)map {
    NSDictionary *data = [map objectForKey:@"data"];
    if (data != nil) {
        NSArray *connections = [data objectForKey:@"connections"];

        NSString *myId = [data objectForKey:@"you"];
//        self.peerConnectionManager joinToRoom(this, connections,true, myId);

    }
}
- (void)sendOffer:(NSString *)socketId sdp:(NSString *)sdp {
    NSDictionary *childMap1 = @{@"type": @"offer", @"sdp": sdp};

    NSDictionary *childMap2 = @{@"socketId": socketId, @"sdp": childMap1};

    NSDictionary *map = @{@"eventName": @"__offer", @"data": childMap2};
//    JSONObject object = new JSONObject(map);
//    String jsonString = object.toString();
    NSLog(@"send-->: %@", map);
//    mWebSocketClient.send(jsonString);
}

- (void)sendAnswer:(NSString *)socketId sdp:(NSString *)sdp {
    NSDictionary *childMap1 = @{@"type": @"answer", @"sdp": sdp};
    
    NSDictionary *childMap2 = @{@"socketId": socketId, @"sdp": childMap1};

    NSDictionary *map = @{@"eventName": @"__answer", @"data": childMap2};
    NSLog(@"send-->: %@", map);
//    mWebSocketClient.send(jsonString);
}

//     message
// 处理交换信息
- (void)handleRemoteCandidate:(NSDictionary *)map {
    NSLog(@"JavaWebSocket  6   handleRemoteCandidate: %@", map);
    NSDictionary *data = [map objectForKey:@"data"];
    if (data != nil) {
        NSString *socketId = [data objectForKey:@"socketId"];
        NSString *sdpMid = [data objectForKey:@"id"];
        sdpMid = (nil == sdpMid) ? @"video" : sdpMid;
        int sdpMLineIndex = [[data objectForKey:@"label"] intValue];
        NSString *candidate = [data objectForKey:@"candidate"];
//        IceCandidate iceCandidate = new IceCandidate(sdpMid, sdpMLineIndex, candidate);
        
        RTCIceCandidate *iceCandidate = [[RTCIceCandidate alloc] initWithSdp:candidate sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
        [_peerConnectionManager onRemoteIceCandidate:iceCandidate fromUserId:socketId];

    }
}

//
// 处理Answer
-(void)handleAnswer:(NSDictionary *)map {
    NSLog(@"handleAnswer: %@", map);
    NSDictionary *data = [map objectForKey:@"data"];
    if (data != nil) {
        NSDictionary *sdpDic = [data objectForKey:@"sdp"];
        NSString *socketId = [data objectForKey:@"socketId"];
//            对方  响应的sdp
        NSString *sdp = [sdpDic objectForKey:@"sdp"];
//        peerConnectionManager.onReceiverAnswer(socketId, sdp);
        RTCSessionDescription *session = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdp];
        [_peerConnectionManager onReceiverAnswer:session fromUserId:socketId];
    }
}

- (void)sendIceCandidate:(NSString *)socketId iceCandidate:(RTCIceCandidate *)iceCandidate {
    NSDictionary *childMap = @{
        @"id": iceCandidate.sdpMid,
        @"label": @(iceCandidate.sdpMLineIndex),
        @"candidate": iceCandidate.sdp,
        @"socketId": socketId
    };
    NSDictionary *map = @{
        @"eventName": @"__ice_candidate",
        @"data": childMap
    };
    NSLog(@"%@", map);
    [_mWebSocketClient sendMessage:map];
}
//----------------------新加---------------------------------


#pragma mark - SocketDelegate 监听服务端发送的消息
- (void)didReceiveAnswer:(NSDictionary<NSString *,id> * _Nonnull)answer {
    // _peerMgr handleAnswer:<#(nonnull RTCSessionDescription *)#> fromUserId:<#(nonnull NSString *)#>
}

- (void)didReceiveCandidate:(NSDictionary<NSString *,id> * _Nonnull)candidate {
    
}

- (void)didReceiveOffer:(NSDictionary<NSString *,id> * _Nonnull)offer {
    
}

- (void)didMessage:(NSDictionary<NSString *,id> *)map {
    NSString *eventName = map[@"type"];
    if ([eventName isEqual: @"join"]) {
        self.joinBlock(@""); // 加入房间成功
    }
    
    // 自己
    if ([eventName isEqual: @"_peers"]) {
        [self hanleJoinRoom:map];
    }
    // 别人
    if ([eventName isEqual: @"_answer"]) {
        [self handleAnswer:map];
    }
    // 不是B端   而是A端
    if ([eventName isEqual: @"_ice_candidate"]) {
        [self handleRemoteCandidate:map];
    }
    // 新用户加入
    if ([eventName isEqual:@"_new_peer"]) {
        [self handleRemoteInRoom:map];
    }
    // 被叫
    if ([eventName isEqual:@"_offer"]) {
        [self handleOffer:map];
    }
}

#pragma mark - PeerConnectionManagerDelegate 监听webrtc获取的sdp, ice
- (void)sendIceCandidate:(RTCIceCandidate *)candidate toUserId:(NSString *)userId {
    NSLog(@"Sending ICE Candidate to %@", userId);
    // Send ICE candidate via WebSocket
    
//    self.socket sendCandidate:<#(NSDictionary<NSString *,id> * _Nonnull)#>
}


- (void)sendAnswer:(nonnull RTCSessionDescription *)answer {
//    NSLog(@"Sending Answer: %@", description);
    // Send answer via WebSocket

}

- (void)sendOffer:(nonnull RTCSessionDescription *)offer {
//    NSLog(@"Sending Offer: %@", description);
    // Send offer via WebSocket

}

@end
