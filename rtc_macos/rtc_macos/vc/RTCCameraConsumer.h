//
//  RTCVideoCaptureSource.h
//  RTCApp
//
//  Created by Jason on 2024/4/23.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCCameraConsumer : NSObject <RTCVideoCapturerDelegate>

@property(nonatomic, copy)void(^didReceiveFrame)(RTCVideoFrame *frame);

@end

NS_ASSUME_NONNULL_END
