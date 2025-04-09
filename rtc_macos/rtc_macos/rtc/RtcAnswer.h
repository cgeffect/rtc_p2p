//
//  Answer.h
//  rtc_macos
//
//  Created by Jason on 2025/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RtcAnswerDelegate <NSObject>

- (void)onIceCandication:(NSString *)candidate;
- (void)onAnswerLocalSdp:(NSString *)sdp;

@end

@interface RtcAnswer : NSObject

@property(nonatomic, weak) id<RtcAnswerDelegate> delegate;

- (void)setRemoteSdp:(NSString *)sdp;
@end

NS_ASSUME_NONNULL_END
