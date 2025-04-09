//
//  RTCViewController.m
//  RTCApp
//
//  Created by Jason on 2024/4/23.
//

#import "RTCViewController.h"
#import <WebRTC/WebRTC.h>

#import "ARDCaptureController.h"
#import "ARDSettingsModel.h"
#import "RTCCameraConsumer.h"
#import "RTCSlideView.h"

#import <rtc_macos-Swift.h>

#import "RtcOffer.h"
#import "RtcAnswer.h"

// 把采集的内容移到OfferController里, 只有Offer才需要采集
@interface RTCViewController ()<RTCVideoViewDelegate, RTCSlideViewDelegate, SignalClientDelegate>
{
    RTCSlideView *_slideView;
    BOOL _device_init;
    RTCCallbackLogger *_rtc_logger;
    SocketClient *_sock;
}
@property(nonatomic, readonly) RTCMTLNSVideoView<RTC_OBJC_TYPE(RTCVideoRenderer)>* localVideoView;
@property(nonatomic, strong) ARDCaptureController *captureController;
@property(nonatomic, strong) RTCCameraConsumer *videoSource;
@property(nonatomic, strong) RtcOffer *offer;
@property(nonatomic, strong) RtcAnswer *answer;
@end

@implementation RTCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addViews];
    
    _videoSource = [[RTCCameraConsumer alloc] init];
    __weak typeof(self) weakSelf = self;
    _videoSource.didReceiveFrame = ^(RTCVideoFrame * _Nonnull frame) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf->_localVideoView renderFrame:frame];
//        [strongSelf->_nativeHdler sendFrame:frame];
    };

    RTC_OBJC_TYPE(RTCCameraVideoCapturer) *localCapturer = [[RTC_OBJC_TYPE(RTCCameraVideoCapturer) alloc] initWithDelegate:_videoSource];
    
    _captureController = [[ARDCaptureController alloc] initWithCapturer:localCapturer settings:[[ARDSettingsModel alloc] init]];

    _sock = [[SocketClient alloc] initWithRoomId:@"1"];
    _sock.delegate = self;
}

- (void)addViews {
    _slideView = [[RTCSlideView alloc] initWithFrame:CGRectMake(0, 0, 100, self.view.frame.size.height)];
    _slideView.delegate = self;
    _slideView.wantsLayer = YES;
    _slideView.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    [self.view addSubview:_slideView];
    
    _localVideoView = [[RTC_OBJC_TYPE(RTCMTLNSVideoView) alloc] initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 100, self.view.frame.size.height)];
    [_localVideoView setSize:CGSizeMake(640, 480)];
    _localVideoView.delegate = self;

    _localVideoView.wantsLayer = YES;
//    _localVideoView.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    [self.view addSubview:_localVideoView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [_slideView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    [_slideView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_slideView autoSetDimensionsToSize:CGSizeMake(300, self.view.frame.size.height)];

    [_localVideoView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_slideView withOffset:0];
    [_localVideoView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [_localVideoView autoSetDimensionsToSize:CGSizeMake((self.view.frame.size.width - _slideView.frame.size.width) / 3, self.view.frame.size.height / 3)];

}

- (void)windowWillClose:(nonnull NSNotification *)notification {
}

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
    
}

#pragma MARK - RTCSlideViewDelegate
- (void)startCapture {
    if (_device_init == YES) {
        return;
    }
    [_captureController startCapture];
//    [_nativeHdler start];
    _device_init = YES;
}

- (void)stopCapture {
    if (_device_init == NO) {
        return;
    }
    [_captureController stopCapture];
//    [_nativeHdler stop];
    _device_init = NO;
}

- (void)startPush:(NSString *)url {
//    [_nativeHdler startPush:url];
}

- (void)registerLog {
    _rtc_logger = [[RTCCallbackLogger alloc] init];
    _rtc_logger.severity = RTCLoggingSeverityVerbose;
    [_rtc_logger start:^(NSString * _Nonnull message) {
        NSLog(@"rtclog: %@", message);
    }];
    [_rtc_logger startWithMessageAndSeverityHandler:^(NSString * _Nonnull message, RTCLoggingSeverity severity) {
        NSLog(@"rtc_log: %@", message);
    }];

//    [_rtc_logger stop];

}

#pragma mark - SignalClientDelegate

// 主叫的回复
- (void)didReceiveAnswer:(NSDictionary<NSString *,id> * _Nonnull)answer {
    
}

// 被叫
- (void)didReceiveOffer:(NSDictionary<NSString *,id> * _Nonnull)offer {
//    [_sock setRole:@"Receiver"];
    NSString *sdp = offer[@"sdp"];
    [_answer setRemoteSdp:sdp];
}

- (void)didReceiveCandidate:(NSDictionary<NSString *,id> * _Nonnull)candidate {
    
}

@end
