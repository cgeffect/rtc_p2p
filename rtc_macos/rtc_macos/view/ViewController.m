//
//  ViewController.m
//  rtc_macos
//
//  Created by Jason on 2025/3/9.
//

#import "ViewController.h"
#import <WebRTC/WebRTC.h>
#import <rtc_macos-Swift.h>
#import "ARDCaptureController.h"

@interface ViewController()<RTCVideoCapturerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//
//    // 初始化 WebRTC 工厂
//    [self createPeerConnectionFactory];
//    
//    
//    // 采集本地媒体流
//    [self captureLocalMedia];
}
//


- (void)capturer:(nonnull RTCVideoCapturer *)capturer didCaptureVideoFrame:(nonnull RTCVideoFrame *)frame {
    NSLog(@"%d", frame.width);
//    if (_didReceiveFrame) {
////        id<RTCVideoFrameBuffer>obj = frame.buffer;
////        RTCVideoFrame *vFrame = [frame newI420VideoFrame];
//        _didReceiveFrame(frame);
//    }
}

@end
