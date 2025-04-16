//
//  AnswerManager.m
//  rtc_macos
//
//  Created by Jason on 2025/3/20.
//

#import "AnswerManager.h"

static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

@interface AnswerManager ()
{
    RTCMTLNSVideoView *_localVideoView;
    RTCMTLNSVideoView *_remoteVideoView;

    RTCAudioTrack *audioTrack;
    RTCVideoTrack *videoTrack;
    RTCCameraVideoCapturer *cameraCapturer;
}
@end

@implementation AnswerManager

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
}

- (void)handleOffer:(RTCSessionDescription *)offer {
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultPeerConnectionConstraints];
    RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
    configuration.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
    
    configuration.iceServers = @[[[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"]]];
    self.peerConnection = [self.factory peerConnectionWithConfiguration:configuration constraints:constraints delegate:self];
//    [self.peerConnection addStream:self.localMediaStream];
    [self.peerConnection addTrack:audioTrack streamIds:@[kARDMediaStreamId]];
    [self.peerConnection addTrack:videoTrack streamIds:@[kARDMediaStreamId]];
    
    [self.peerConnection setRemoteDescription:offer completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error setting remote description: %@", error);
            return;
        }
        [self.peerConnection answerForConstraints:[self defaultAnswerConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error creating answer: %@", error);
                return;
            }
            [self.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    NSLog(@"Error setting local description: %@", error);
                    return;
                }
                // 通过代理发送Answer
                [self.delegate sendAnswer:sdp];
            }];
        }];
    }];
}

- (void)stopCall {
    [cameraCapturer stopCaptureWithCompletionHandler:^{
            
    }];
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

- (RTC_OBJC_TYPE(RTCMediaConstraints) *)defaultAnswerConstraints {
    return [self defaultOfferConstraints];
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


/*
 #import "AppDelegate.h"
 #import "OfferManager.h"
 #import "AnswerManager.h"

 @interface AppDelegate () <PeerConnectionManagerDelegate>
 @property (nonatomic, strong) RTCPeerConnectionFactory *factory;
 @property (nonatomic, strong) OfferManager *offerManager;
 @property (nonatomic, strong) AnswerManager *answerManager;
 @end

 @implementation AppDelegate

 - (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
     self.factory = [[RTCPeerConnectionFactory alloc] init];

     // 创建 OfferManager
     self.offerManager = [[OfferManager alloc] initWithFactory:self.factory
                                                        roomId:@"12345"
                                                        userId:@"user1"
                                                      delegate:self];
     [self.offerManager startCall];

     // 创建 AnswerManager
     self.answerManager = [[AnswerManager alloc] initWithFactory:self.factory
                                                           roomId:@"12345"
                                                           userId:@"user2"
                                                         delegate:self];
     // 假设收到 Offer
     RTCSessionDescription *offer = ...; // 从信令服务器接收的 Offer
     [self.answerManager handleOffer:offer];
 }

 - (void)sendOffer:(RTCSessionDescription *)offer {
     NSLog(@"Sending Offer: %@", offer.sdp);
     // 通过信令服务器发送 Offer
 }

 - (void)sendAnswer:(RTCSessionDescription *)answer {
     NSLog(@"Sending Answer: %@", answer.sdp);
     // 通过信令服务器发送 Answer
 }

 @end
 */
