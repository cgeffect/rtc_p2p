//
//  WebRTCManager.m
//  rtc_macos
//
//  Created by Jason on 2025/3/19.
//

#import "WebRTCManager.h"
#import "WebSocketManager.h"
#import "PeerConnectionManager.h"

#import "WebRTCManager.h"

@interface WebRTCManager ()

@property (nonatomic, strong) WebSocketManager *webSocketManager;
@property (nonatomic, strong) PeerConnectionManager *peerConnectionManager;
@property (nonatomic, strong) NSString *roomId;

@end

@implementation WebRTCManager

+ (instancetype)sharedInstance {
    static WebRTCManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化代码
    }
    return self;
}

- (void)connect:(NSString *)ws {
    self.peerConnectionManager = [[PeerConnectionManager alloc] initWithContext:@""];
    self.webSocketManager = [[WebSocketManager alloc] initWithPeer:self.peerConnectionManager];
    [self.webSocketManager connect:ws];
}

- (void)joinRoomId:(NSString *)roomId handler:(void (^)(NSString * _Nonnull))block {
    self.roomId = roomId;
    [self.webSocketManager joinRoom:self.roomId handler:^(NSString * _Nonnull roomId) {
        block(roomId);
    }];
}

@end
