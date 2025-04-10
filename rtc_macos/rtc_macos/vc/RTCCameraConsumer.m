//
//  RTCVideoCaptureSource.m
//  RTCApp
//
//  Created by Jason on 2024/4/23.
//

#import "RTCCameraConsumer.h"

@implementation RTCCameraConsumer

- (void)capturer:(nonnull RTCVideoCapturer *)capturer didCaptureVideoFrame:(nonnull RTCVideoFrame *)frame { 
    if (_didReceiveFrame) {
//        id<RTCVideoFrameBuffer>obj = frame.buffer;
//        RTCVideoFrame *vFrame = [frame newI420VideoFrame];
        _didReceiveFrame(frame);
    }
}

@end
