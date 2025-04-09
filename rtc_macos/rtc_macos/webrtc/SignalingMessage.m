//
//  SignalingMessage.m
//  rtc_macos
//
//  Created by Jason on 2025/3/20.
//

#import "SignalingMessage.h"

@implementation SignalingMessage

- (instancetype)initWithType:(SignalingMessageType)type
                      roomId:(NSString *)roomId
                      userId:(NSString *)userId
                         sdp:(NSString *)sdp
                   candidate:(RTCIceCandidate *)candidate {
    self = [super init];
    if (self) {
        _type = type;
        _roomId = roomId;
        _userId = userId;
        _sdp = sdp;
        _candidate = candidate;
    }
    return self;
}

@end
