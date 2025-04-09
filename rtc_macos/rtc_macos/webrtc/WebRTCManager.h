//
//  WebRTCManager.h
//  rtc_macos
//
//  Created by Jason on 2025/3/19.
//

#import <Foundation/Foundation.h>
#import "WebSocketManager.h"
#import "PeerConnectionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebRTCManager : NSObject

+ (instancetype)sharedInstance;

- (void)connect:(NSString *)ws;
- (void)joinRoomId:(NSString *)roomId handler:(void(^)(NSString *roomId))block;

@end

NS_ASSUME_NONNULL_END
