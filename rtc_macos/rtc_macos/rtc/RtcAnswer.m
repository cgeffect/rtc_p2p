//
//  Answer.m
//  rtc_macos
//
//  Created by Jason on 2025/3/12.
//

#import "RtcAnswer.h"
#import <rtc_macos-Swift.h>

@interface RtcAnswer ()<SignalClientDelegate>
@property (nonatomic, strong) SocketClient* sock;
@end

@implementation RtcAnswer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sock.delegate = self;
    }
    return self;
}

- (void)setRemoteSdp:(NSString *)sdp {
    
}

#pragma mark - SignalClientDelegate
- (void)didReceiveAnswer:(NSDictionary<NSString *,id> * _Nonnull)answer {
    
}

- (void)didReceiveCandidate:(NSDictionary<NSString *,id> * _Nonnull)candidate { 
        
}

- (void)didReceiveOffer:(NSDictionary<NSString *,id> * _Nonnull)offer { 
    
}

@end
