//
//  OfferManager.h
//  rtc_macos
//
//  Created by Jason on 2025/3/20.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PeerConnectionManagerDelegate <NSObject>

// 发送 Offer
- (void)sendOffer:(RTCSessionDescription *)offer;

// 发送 Answer
- (void)sendAnswer:(RTCSessionDescription *)answer;

// 发送 ICE 候选
- (void)sendIceCandidate:(RTCIceCandidate *)candidate toUserId:(NSString *)userId;

@end

@interface OfferManager : NSObject <RTCPeerConnectionDelegate>

//@property (nonatomic, strong) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, weak) id<PeerConnectionManagerDelegate> delegate;

- (instancetype)initWithFactory:(RTCPeerConnectionFactory *)factory
                        roomId:(NSString *)roomId
                        userId:(NSString *)userId
                       delegate:(id<PeerConnectionManagerDelegate>)delegate;

- (void)startCall;
- (void)stopCall;

- (void)setRemoteSdp:(RTCSessionDescription *)sdp;

- (RTCMTLNSVideoView *)getLocalVideoView;
- (RTCMTLNSVideoView *)getRemoteVideoView;

@end

NS_ASSUME_NONNULL_END
