//
//  WebRTCCommunicator.h
//  rtc_macos
//
//  Created by Jason on 2025/3/12.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@interface RtcOffer : NSObject

@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCVideoTrack *localVideoTrack;
@property (nonatomic, strong) RTCAudioTrack *localAudioTrack;

- (instancetype)init;
- (void)setupPeerConnectionFactory;

@end

NS_ASSUME_NONNULL_END
