//
//  OfferManager.m
//  rtc_macos
//
//  Created by Jason on 2025/3/20.
//

#import "OfferManager.h"

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
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultMediaAudioConstraints];

    self.localMediaStream = [self.factory mediaStreamWithStreamId:@"ARDAMS"];
    RTCAudioSource *audioSource = [self.factory audioSourceWithConstraints:constraints];
    RTCAudioTrack *audioTrack = [self.factory audioTrackWithSource:audioSource trackId:@"ARDAMSa0"];
    [self.localMediaStream addAudioTrack:audioTrack];

    RTCVideoSource *videoSource = [self.factory videoSource];
    RTCCameraVideoCapturer *cameraCapturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
    AVCaptureDevice *device = [RTCCameraVideoCapturer captureDevices][0];
    [cameraCapturer startCaptureWithDevice:device format:[RTCCameraVideoCapturer supportedFormatsForDevice:device][0] fps:30];
    RTCVideoTrack *videoTrack = [self.factory videoTrackWithSource:videoSource trackId:@"ARDAMSv0"];
    [self.localMediaStream addVideoTrack:videoTrack];
}

- (void)startCall {
    RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultPeerConnectionConstraints];
    RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
    configuration.iceServers = @[[[RTCIceServer alloc] initWithURLStrings:@[@"stun:stun.l.google.com:19302"]]];
    self.peerConnection = [self.factory peerConnectionWithConfiguration:configuration constraints:constraints delegate:self];
    [self.peerConnection addStream:self.localMediaStream];

    [self.peerConnection offerForConstraints:[self defaultOfferConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error creating offer: %@", error);
            return;
        }
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
