//
//  WebSocketManager.h
//  rtc_macos
//
//  Created by Jason on 2025/3/19.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "PeerConnectionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebSocketManager : NSObject
- (instancetype)initWithPeer:(PeerConnectionManager *)peerMgr;
- (void)connect:(NSString *)ws;
- (void)joinRoom:(NSString *)roomId handler:(void(^)(NSString *roomId))block;
@end

NS_ASSUME_NONNULL_END
