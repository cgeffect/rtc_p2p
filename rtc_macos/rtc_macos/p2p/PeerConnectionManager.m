//
//  PeerConnectionManager.m
//  rtc_macos
//
//  Created by Jason on 2025/3/19.
//

#import "PeerConnectionManager.h"

@interface PeerConnectionManager ()<RTCPeerConnectionDelegate>
@property (nonatomic, assign) BOOL isScreenCast;
@end

@implementation PeerConnectionManager
- (instancetype)initWithContext:(NSString *)context {
    self = [super init];
    if (self) {
        self.factory = [[RTCPeerConnectionFactory alloc] init];
        self.peerConnections = [NSMutableDictionary dictionary];
        self.role = WebRTCRoleUnknown;
        // 初始化本地媒体流
        [self createLocalStream];
    }
    return self;
}

- (void)createLocalStream {
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultMediaAudioConstraints];

    // 创建音频和视频轨道
    self.localMediaStream = [self.factory mediaStreamWithStreamId:@"ARDAMS"];
    RTCAudioSource *audioSource = [self.factory audioSourceWithConstraints:constraints];
    RTCAudioTrack *audioTrack = [self.factory audioTrackWithSource:audioSource trackId:@"ARDAMSa0"];
    [self.localMediaStream addAudioTrack:audioTrack];

    if (_isScreenCast) {
        // 录屏
        RTCVideoSource *videoSource = [self.factory videoSourceForScreenCast:true];
        RTCVideoTrack *videoTrack = [self.factory videoTrackWithSource:videoSource trackId:@"ARDAMSv0"];
        [self.localMediaStream addVideoTrack:videoTrack];
    } else {
        // 创建视频源
        RTCVideoSource *videoSource = [self.factory videoSource];

        // 创建摄像头视频捕获器
        RTCCameraVideoCapturer *cameraCapturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];

        // 选择摄像头设备
        AVCaptureDevice *device = [RTCCameraVideoCapturer captureDevices][0];

        // 开始捕获
        [cameraCapturer startCaptureWithDevice:device format:[RTCCameraVideoCapturer supportedFormatsForDevice:device][0] fps:30];

        RTCVideoTrack *videoTrack = [self.factory videoTrackWithSource:videoSource trackId:@"ARDAMSv0"];
        [self.localMediaStream addVideoTrack:videoTrack];
    }
}

- (void)startCallWithRoomId:(NSString *)roomId {
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultPeerConnectionConstraints];

    // 创建PeerConnection
    RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
    configuration.iceServers = @[[[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"]]];
    RTCPeerConnection *peerConnection = [self.factory peerConnectionWithConfiguration:configuration constraints:constraints delegate:self];
    [peerConnection addStream:self.localMediaStream];
    self.peerConnections[roomId] = peerConnection;

    // 创建Offer
    [peerConnection offerForConstraints:[self defaultOfferConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error creating offer: %@", error);
            return;
        }
        [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error setting local description: %@", error);
                return;
            }
            // 通过代理发送Offer
            [self.delegate sendOffer:peerConnection.localDescription];
        }];
    }];
    self.role = WebRTCRoleOfferer;
}

- (void)onRemoteJoinToRoom:(nonnull NSString *)socketId {
}

- (void)onReceiveOffer:(RTCSessionDescription *)offer fromUserId:(NSString *)userId {
    if (self.role != WebRTCRoleUnknown) {
        NSLog(@"Already in a call, ignoring new offer.");
        return;
    }

    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultPeerConnectionConstraints];

    // 创建PeerConnection
    RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
    configuration.iceServers = @[[[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"]]];
    RTCPeerConnection *peerConnection = [self.factory peerConnectionWithConfiguration:configuration constraints:constraints delegate:self];
    [peerConnection addStream:self.localMediaStream];
    self.peerConnections[userId] = peerConnection;
    
    __weak PeerConnectionManager *weakSelf = self;
    // 设置远端描述
    [peerConnection setRemoteDescription:offer completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error setting remote description: %@", error);
            return;
        }
        PeerConnectionManager *strongSelf = weakSelf;
        // 创建Answer
        [peerConnection answerForConstraints:[strongSelf defaultAnswerConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error creating answer: %@", error);
                return;
            }
            [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error setting local description: %@", error);
                    return;
                }
                // 通过代理发送Answer
                [strongSelf.delegate sendAnswer:peerConnection.localDescription];
            }];
        }];
    }];
    self.role = WebRTCRoleAnswerer;
}

- (void)onReceiverAnswer:(RTCSessionDescription *)answer fromUserId:(NSString *)userId {
    RTCPeerConnection *peerConnection = self.peerConnections[userId];
    if (peerConnection) {
        [peerConnection setRemoteDescription:answer completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error setting remote description: %@", error);
            }
        }];
    }
}

- (void)onRemoteIceCandidate:(RTCIceCandidate *)candidate fromUserId:(NSString *)userId {
    RTCPeerConnection *peerConnection = self.peerConnections[userId];
    if (peerConnection) {
        [peerConnection addIceCandidate:candidate completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error adding ICE candidate: %@", error);
            }
        }];
    }
}

#pragma mark - defaults
- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultMediaAudioConstraints {
    NSDictionary *mandatoryConstraints = @{};
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints =
        [[RTC_OBJC_TYPE(RTCMediaConstraints) alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                         optionalConstraints:nil];
    return constraints;
}

- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
}

- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultOfferConstraints {
    NSDictionary *mandatoryConstraints = @{
        @"OfferToReceiveAudio" : @"true",
        @"OfferToReceiveVideo" : @"true"
    };
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints =
        [[RTC_OBJC_TYPE(RTCMediaConstraints) alloc] initWithMandatoryConstraints:mandatoryConstraints
                                                         optionalConstraints:nil];
    return constraints;
}

- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultPeerConnectionConstraints {
    NSString *value = @"true";
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : value };
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints =
        [[RTC_OBJC_TYPE(RTCMediaConstraints) alloc] initWithMandatoryConstraints:nil
                                                         optionalConstraints:optionalConstraints];
    return constraints;
}

#pragma mark - RTCPeerConnectionDelegate
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    NSString *userId = [self userIdForPeerConnection:peerConnection];
    if (userId) {
        // 通过代理发送ICE候选
        [self.delegate sendIceCandidate:candidate toUserId:userId];
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream {
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState { 
    
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

- (NSString *)userIdForPeerConnection:(RTCPeerConnection *)peerConnection {
    for (NSString *userId in self.peerConnections) {
        if (self.peerConnections[userId] == peerConnection) {
            return userId;
        }
    }
    return nil;
}

@end
