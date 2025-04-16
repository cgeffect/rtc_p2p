//
//  AnswerManager.h
//  rtc_macos
//
//  Created by Jason on 2025/3/20.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "OfferManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnswerManager : NSObject <RTCPeerConnectionDelegate>

@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
//@property (nonatomic, strong) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, weak) id<PeerConnectionManagerDelegate> delegate;

- (instancetype)initWithFactory:(RTCPeerConnectionFactory *)factory
                        roomId:(NSString *)roomId
                        userId:(NSString *)userId
                       delegate:(id<PeerConnectionManagerDelegate>)delegate;

- (void)handleOffer:(RTCSessionDescription *)offer;

- (void)stopCall;

- (RTCMTLNSVideoView *)getLocalVideoView;
- (RTCMTLNSVideoView *)getRemoteVideoView;

@end

NS_ASSUME_NONNULL_END
