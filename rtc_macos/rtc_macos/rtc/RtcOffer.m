//
//  WebRTCCommunicator.m
//  rtc_macos
//
//  Created by Jason on 2025/3/12.
//

#import "RtcOffer.h"

@interface RtcOffer ()<RTCPeerConnectionDelegate>

@end

@implementation RtcOffer

//1. 初始化 WebRTC 环境
//
//首先要创建 RTCPeerConnectionFactory，它是 WebRTC 中创建各种对象的工厂类。
- (instancetype)init {
    self = [super init];
    if (self) {
        // 使用默认的编解码器
        self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] init];
        
        // 使用自定义
        RTCVideoEncoderFactoryH264 *encoderFactory = [[RTCVideoEncoderFactoryH264 alloc] init];
        NSArray *codecArray = [encoderFactory supportedCodecs];
        
        RTCVideoDecoderFactoryH264 *decoderFactory = [[RTCVideoDecoderFactoryH264 alloc] init];
        self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory decoderFactory:decoderFactory];
        
        
//        self.peerConnectionFactory = [RTCPeerConnectionFactory alloc] initWithEncoderFactory:<#(nullable id<RTCVideoEncoderFactory>)#> decoderFactory:<#(nullable id<RTCVideoDecoderFactory>)#> audioDevice:<#(nullable id<RTCAudioDevice>)#>
        
    }
    return self;
}

//2. 采集音视频数据
//
//使用 WebRTC 提供的 API 来采集本地的音视频数据。
// 对于视频，可以使用 RTCVideoSource 和 RTCVideoTrack；
// 对于音频，可以使用 RTCAudioSource 和 RTCAudioTrack。
- (void)setupLocalMediaStreams {
    // 视频采集
    RTCVideoSource *videoSource = [self.peerConnectionFactory videoSource];
    self.localVideoTrack = [self.peerConnectionFactory videoTrackWithSource:videoSource trackId:@"video0"];
    
    // 音频采集
    RTCAudioSource *audioSource = [self.peerConnectionFactory audioSourceWithConstraints:nil];
    self.localAudioTrack = [self.peerConnectionFactory audioTrackWithSource:audioSource trackId:@"audio0"];
    
    // 创建媒体流并添加音视频轨道
    RTCMediaStream *localStream = [self.peerConnectionFactory mediaStreamWithStreamId:@"stream1"];
    [localStream addVideoTrack:self.localVideoTrack];
    [localStream addAudioTrack:self.localAudioTrack];
    
    // 将媒体流添加到 PeerConnection
    [self.peerConnection addStream:localStream];
}

//3. 创建和配置 PeerConnection
//
//创建 RTCPeerConnection 并配置相关参数，如 ICE 服务器等。
- (void)createPeerConnection {
    RTCConfiguration *config = [[RTCConfiguration alloc] init];
    config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    
    // 设置 ICE 服务器，这里使用 Google 的 STUN 服务器作为示例
    RTCIceServer *iceServer = [[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"]];
    NSArray<RTCIceServer *> *iceServers = @[iceServer];
    config.iceServers = iceServers;
    
    self.peerConnection = [self.peerConnectionFactory peerConnectionWithConfiguration:config
                                                                          constraints:nil
                                                                         delegate:self];
}

//4. 进行 SDP 和 ICE 候选交换
//
//通过信令服务器交换 SDP（会话描述协议）和 ICE 候选，以建立连接。Offer 端创建 Offer SDP，设置本地描述并发送给对端；Answer 端接收 Offer SDP，设置远程描述，创建 Answer SDP 并发送给 Offer 端。同时，两端都要交换 ICE 候选。

// 创建 Offer
- (void)createOffer {
    [self.peerConnection offerForConstraints:nil completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error creating offer: %@", error);
            return;
        }
        
        [self.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error setting local description: %@", error);
            } else {
                // 将 Offer SDP 发送给对端
                [self sendSDPToPeer:sdp];
            }
        }];
    }];
}

// 处理接收到的远程 Offer SDP
- (void)handleRemoteOffer:(RTCSessionDescription *)remoteSdp {
    [self.peerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error setting remote description: %@", error);
            return;
        }
        
        [self.peerConnection answerForConstraints:nil completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error creating answer: %@", error);
                return;
            }
            
            [self.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error setting local description for answer: %@", error);
                } else {
                    // 将 Answer SDP 发送给对端
                    [self sendSDPToPeer:sdp];
                }
            }];
        }];
    }];
}

// 发送 SDP 给对端
- (void)sendSDPToPeer:(RTCSessionDescription *)sdp {
    // 实现具体的发送逻辑，例如通过 WebSocket 发送
    // 这里只是简单打印，实际开发中需要替换为真实的发送代码
    NSLog(@"Sending SDP to peer: %@", sdp.description);
}

// 处理接收到的 ICE 候选
- (void)handleRemoteIceCandidate:(RTCIceCandidate *)candidate {
    [self.peerConnection addIceCandidate:candidate completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error adding ICE candidate: %@", error);
        }
    }];
}

// 生成 ICE 候选时的回调
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    // 将 ICE 候选发送给对端
    [self sendIceCandidateToPeer:candidate];
}

// 发送 ICE 候选给对端
- (void)sendIceCandidateToPeer:(RTCIceCandidate *)candidate {
    // 实现具体的发送逻辑，例如通过 WebSocket 发送
    // 这里只是简单打印，实际开发中需要替换为真实的发送代码
    NSLog(@"Sending ICE candidate to peer: %@", candidate.sdp);
}

//5. 发送音视频数据
//
//一旦 PeerConnection 建立成功（RTCIceConnectionStateConnected 状态），WebRTC 会自动将本地采集的音视频数据通过连接发送给对端，无需额外的操作。可以通过监听 RTCPeerConnection 的状态变化来确认连接是否建立成功。

#pragma mark - RTCPeerConnectionDelegate
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    if (newState == RTCIceConnectionStateConnected) {
        NSLog(@"ICE connection established. Audio and video data will be sent automatically.");
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream { 
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState { 
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged { 
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didOpenDataChannel:(nonnull RTCDataChannel *)dataChannel { 
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates { 
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream { 
    
}


- (void)peerConnectionShouldNegotiate:(nonnull RTCPeerConnection *)peerConnection { 
    
}

#pragma mark - @optional
/** Called any time the IceConnectionState changes following standardized
 * transition. */
- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection didChangeStandardizedIceConnectionState:(RTCIceConnectionState)newState {
    
}

/** Called any time the PeerConnectionState changes. */
- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection didChangeConnectionState:(RTCPeerConnectionState)newState {
    
}

- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection didStartReceivingOnTransceiver:(RTC_OBJC_TYPE(RTCRtpTransceiver) *)transceiver {
    
}

/** Called when a receiver and its track are created. */
- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection
        didAddReceiver:(RTC_OBJC_TYPE(RTCRtpReceiver) *)rtpReceiver
               streams:(NSArray<RTC_OBJC_TYPE(RTCMediaStream) *> *)mediaStreams {
    
}

/** Called when the receiver and its track are removed. */
- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection didRemoveReceiver:(RTC_OBJC_TYPE(RTCRtpReceiver) *)rtpReceiver {
    
}

/** Called when the selected ICE candidate pair is changed. */
- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection 
didChangeLocalCandidate:(RTC_OBJC_TYPE(RTCIceCandidate) *)local
       remoteCandidate:(RTC_OBJC_TYPE(RTCIceCandidate) *)remote
        lastReceivedMs:(int)lastDataReceivedMs
          changeReason:(NSString *)reason {
    
}

/** Called when gathering of an ICE candidate failed. */
- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection didFailToGatherIceCandidate:(RTC_OBJC_TYPE(RTCIceCandidateErrorEvent) *)event {
    
}


/*
 // 初始化 WebRTC 管理器
 WebRTCManager *manager = [[WebRTCManager alloc] init];

 // 创建 PeerConnection
 [manager createPeerConnection];

 // 设置本地媒体流
 [manager setupLocalMediaStreams];

 // 作为 Offer 端发起会话
 [manager createOffer];

 // 模拟接收远程 Offer SDP 和 ICE 候选
 // 实际开发中需要通过信令服务器接收
 RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:@"remote offer sdp here"];
 [manager handleRemoteOffer:remoteSdp];

 RTCIceCandidate *remoteCandidate = [[RTCIceCandidate alloc] initWithSdp:@"remote ice candidate sdp here" sdpMLineIndex:0 sdpMid:@"mid"];
 [manager handleRemoteIceCandidate:remoteCandidate];
 */
@end
