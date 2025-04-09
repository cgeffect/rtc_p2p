//
//  SignalingMessage.h
//  rtc_macos
//
//  Created by Jason on 2025/3/20.
//

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SignalingMessageType) {
    SignalingMessageTypeJoin,
    SignalingMessageTypeOffer,
    SignalingMessageTypeAnswer,
    SignalingMessageTypeCandidate,
    SignalingMessageTypeError
};

@interface SignalingMessage : NSObject

@property (nonatomic, assign) SignalingMessageType type;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *sdp;
@property (nonatomic, strong) RTCIceCandidate *candidate;

- (instancetype)initWithType:(SignalingMessageType)type
                      roomId:(NSString *)roomId
                      userId:(NSString *)userId
                         sdp:(NSString *)sdp
                   candidate:(RTCIceCandidate *)candidate;

@end

NS_ASSUME_NONNULL_END
