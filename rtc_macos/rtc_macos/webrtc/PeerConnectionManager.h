//
//  PeerConnectionManager.h
//  rtc_macos
//
//  Created by Jason on 2025/3/19.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WebRTCRole) {
    WebRTCRoleUnknown,
    WebRTCRoleOfferer,
    WebRTCRoleAnswerer
};

@protocol PeerConnectionManagerDelegate <NSObject>
- (void)sendOffer:(RTCSessionDescription *)offer;
- (void)sendAnswer:(RTCSessionDescription *)answer;
- (void)sendIceCandidate:(RTCIceCandidate *)candidate toUserId:(NSString *)userId;
@end

@interface PeerConnectionManager : NSObject

@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCMediaStream *localMediaStream;
@property (nonatomic, strong) NSMutableDictionary<NSString *, RTCPeerConnection *> *peerConnections;
@property (nonatomic, assign) WebRTCRole role;
@property (nonatomic, weak) id<PeerConnectionManagerDelegate> delegate;

- (instancetype)initWithContext:(NSString *)context;
- (void)startCallWithRoomId:(NSString *)roomId;
- (void)onReceiverAnswer:(RTCSessionDescription *)offer fromUserId:(NSString *)userId;
- (void)onReceiveOffer:(RTCSessionDescription *)answer fromUserId:(NSString *)userId;
- (void)onRemoteIceCandidate:(RTCIceCandidate *)candidate fromUserId:(NSString *)userId;
- (void)onRemoteJoinToRoom:(NSString *)socketId;
@end

NS_ASSUME_NONNULL_END
