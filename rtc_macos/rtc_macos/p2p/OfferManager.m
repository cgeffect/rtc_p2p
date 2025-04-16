//
//  OfferManager.m
//  rtc_macos
//
//  Created by Jason on 2025/3/20.
//

#import "OfferManager.h"

static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

@interface OfferManager ()
{
    RTCMTLNSVideoView *_localVideoView;
    RTCMTLNSVideoView *_remoteVideoView;
    RTCCameraVideoCapturer *cameraCapturer;
    RTCAudioTrack *audioTrack;
    RTCVideoTrack *videoTrack;
}
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;

@end

@implementation OfferManager

- (instancetype)initWithFactory:(RTCPeerConnectionFactory *)factory
                        roomId:(NSString *)roomId
                        userId:(NSString *)userId
                       delegate:(id<PeerConnectionManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.factory = factory;
        self.roomId = roomId;
        self.userId = userId;
        self.delegate = delegate;
        [self createLocalStream];
    }
    return self;
}

- (void)createLocalStream {
    _localVideoView = [[RTCMTLNSVideoView alloc] initWithFrame:NSMakeRect(0, 0, 640, 480)];
    _remoteVideoView = [[RTCMTLNSVideoView alloc] initWithFrame:NSMakeRect(0, 0, 640, 480)];

    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultMediaAudioConstraints];

//    self.localMediaStream = [self.factory mediaStreamWithStreamId:kARDMediaStreamId];
    RTCAudioSource *audioSource = [self.factory audioSourceWithConstraints:constraints];
    audioTrack = [self.factory audioTrackWithSource:audioSource trackId:kARDAudioTrackId];
//    [self.localMediaStream addAudioTrack:audioTrack];

    RTCVideoSource *videoSource = [self.factory videoSource];
    cameraCapturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
    AVCaptureDevice *device = [RTCCameraVideoCapturer captureDevices][0];
    [cameraCapturer startCaptureWithDevice:device format:[RTCCameraVideoCapturer supportedFormatsForDevice:device][0] fps:30];
    videoTrack = [self.factory videoTrackWithSource:videoSource trackId:kARDVideoTrackId];
//    [self.localMediaStream addVideoTrack:videoTrack];
    
    // 显示自己的画面
    [videoTrack addRenderer:_localVideoView];
}

- (void)startCall {
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultPeerConnectionConstraints];
    RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
    
    // RTCSdpSemanticsPlanB 是旧版本,RTCSdpSemanticsUnifiedPlan是新版本, 使用RTCSdpSemanticsUnifiedPlan必须使用addTrack, 不能使用addStream
    configuration.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    configuration.iceServers = @[[[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"]]];
    self.peerConnection = [self.factory peerConnectionWithConfiguration:configuration constraints:constraints delegate:self];
//    [self.peerConnection addStream:self.localMediaStream];
    
    RTCRtpSender *audioSender = [self.peerConnection addTrack:audioTrack streamIds:@[kARDMediaStreamId]];
    RTCRtpSender *videoSender = [self.peerConnection addTrack:videoTrack streamIds:@[kARDMediaStreamId]];
    
    [self.peerConnection offerForConstraints:[self defaultOfferConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error creating offer: %@", error);
            return;
        }
        NSLog(@"%@", sdp.description);
        [self.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error setting local description: %@", error);
                return;
            }
            // 通过代理发送Offer
            [self.delegate sendOffer:sdp];
        }];
    }];
}

- (void)stopCall {
    [cameraCapturer stopCaptureWithCompletionHandler:^{
            
    }];
}

// 接收到对方的 sdp
- (void)setRemoteSdp:(RTCSessionDescription *)sdp {
    [self.peerConnection setRemoteDescription:sdp completionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"set remote sdp error: %@", error);
            return;
        }
    }];
}

// 接收到对方的 ICE 候选者
- (void)addIceCandidate:(RTCIceCandidate *)candidate {
    [self.peerConnection addIceCandidate:candidate completionHandler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - RTCPeerConnectionDelegate
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream {
    // 遍历对方的视频轨道并添加到远程视频视图
    for (RTCVideoTrack *videoTrack in stream.videoTracks) {
        [videoTrack addRenderer:_remoteVideoView];
    }
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState { 
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged { 
    
}
// 收集到 ICE 候选者
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didGenerateIceCandidate:(nonnull RTCIceCandidate *)candidate {
    if (candidate) {
        // 发送 ICE 候选者到对方
        [self.delegate sendIceCandidate:candidate toUserId:@""];
    } else {
        NSLog(@"ICE candidate gathering complete.");
    }
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didOpenDataChannel:(nonnull RTCDataChannel *)dataChannel { 
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates { 
    
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream { 
    
}

- (void)peerConnectionShouldNegotiate:(nonnull RTCPeerConnection *)peerConnection { 
    
}

- (RTCMTLNSVideoView *)getLocalVideoView {
    return _localVideoView;
}
- (RTCMTLNSVideoView *)getRemoteVideoView {
    return _remoteVideoView;
}

- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultMediaAudioConstraints {
    NSDictionary *mandatoryConstraints = @{};
    return [[RTC_OBJC_TYPE(RTCMediaConstraints) alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
}

- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultOfferConstraints {
    NSDictionary *mandatoryConstraints = @{
        @"OfferToReceiveAudio" : @"true",
        @"OfferToReceiveVideo" : @"true"
    };
    return [[RTC_OBJC_TYPE(RTCMediaConstraints) alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:nil];
}

- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultPeerConnectionConstraints {
    NSString *value = @"true";
    NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : value };
    return [[RTC_OBJC_TYPE(RTCMediaConstraints) alloc] initWithMandatoryConstraints:nil optionalConstraints:optionalConstraints];
}
@end
