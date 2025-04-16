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
#import "OfferManager.h"

// 把采集的内容移到OfferController里, 只有Offer才需要采集
@interface RTCViewController ()<PeerConnectionManagerDelegate, SignalClientDelegate>
{
    RTCSlideView *_slideView;
    BOOL _device_init;
    RTCCallbackLogger *_rtc_logger;
    SocketClient *_sock;
    
    OfferManager *_offer;
}
@property(nonatomic, readonly) RTCMTLNSVideoView<RTC_OBJC_TYPE(RTCVideoRenderer)>* localVideoView;
@property(nonatomic, strong) ARDCaptureController *captureController;
@property(nonatomic, strong) RTCCameraConsumer *videoSource;
//@property(nonatomic, strong) RtcOffer *offer;
//@property(nonatomic, strong) RtcAnswer *answer;
@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@end

@implementation RTCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addViews];

//    // 实现了RTCCameraVideoCapturer协议的中间层, 采集的数据会先被发送到RTCCameraConsumer, 再由RTCCameraConsumer回调出来
//    _videoSource = [[RTCCameraConsumer alloc] init];
//    __weak typeof(self) weakSelf = self;
//    _videoSource.didReceiveFrame = ^(RTCVideoFrame * _Nonnull frame) {
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        [strongSelf->_localVideoView renderFrame:frame];
////        [strongSelf->_nativeHdler sendFrame:frame];
//    };
//
//    RTC_OBJC_TYPE(RTCCameraVideoCapturer) *localCapturer = [[RTC_OBJC_TYPE(RTCCameraVideoCapturer) alloc] initWithDelegate:_videoSource];
//    
//    _captureController = [[ARDCaptureController alloc] initWithCapturer:localCapturer settings:[[ARDSettingsModel alloc] init]];
//
    _sock = [[SocketClient alloc] initWithRoomId:@"1"];
    _sock.delegate = self;
    
    self.factory = [[RTCPeerConnectionFactory alloc] init];

}

- (void)addViews {
    _slideView = [[RTCSlideView alloc] initWithFrame:CGRectMake(0, 0, 100, self.view.frame.size.height)];
    _slideView.wantsLayer = YES;
    _slideView.layer.backgroundColor = [NSColor darkGrayColor].CGColor;
    [self.view addSubview:_slideView];
    
    __weak typeof(self) weakSelf = self;
    [_slideView setStartCapture:^{
        __strong typeof(weakSelf) strongSelf = weakSelf; // 如果需要在 block 内部使用 self，可以将其转换为强引用
        strongSelf->_offer = [[OfferManager alloc] initWithFactory:self.factory roomId:@"" userId:@"" delegate:self];

        [strongSelf->_offer startCall];
        
        strongSelf->_localVideoView = [strongSelf->_offer getLocalVideoView];
        
        [strongSelf.view addSubview:strongSelf->_localVideoView];

//        [strongSelf->_localVideoView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:strongSelf->_slideView withOffset:50];
//        [strongSelf->_localVideoView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.f];
//        [strongSelf->_localVideoView autoSetDimensionsToSize:CGSizeMake(300, 300)];
            
        [strongSelf updateViewConstraints];
    }];
    
    [_slideView setStopCapture:^{
        __strong typeof(weakSelf) strongSelf = weakSelf; // 如果需要在 block 内部使用 self，可以将其转换为强引用
        [strongSelf->_offer stopCall];
    }];
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
//    [_answer setRemoteSdp:sdp];
}

- (void)didReceiveCandidate:(NSDictionary<NSString *,id> * _Nonnull)candidate {
    
}

- (void)didMessage:(NSDictionary<NSString *,id> * _Nonnull)msg { 
    
}

#pragma mark - PeerConnectionManagerDelegate

- (void)sendOffer:(nonnull RTCSessionDescription *)offer {
    [_sock sendOffer:@{}];
}

- (void)sendAnswer:(nonnull RTCSessionDescription *)answer {
    
}

- (void)sendIceCandidate:(nonnull RTCIceCandidate *)candidate toUserId:(nonnull NSString *)userId { 
    
}

#pragma mark -

- (void)windowWillClose:(nonnull NSNotification *)notification {
}

@end
