//
//  RTCSlideView.h
//  RTCApp
//
//  Created by Jason on 2024/4/24.
//

#import <Cocoa/Cocoa.h>
#import <PureLayout/PureLayout.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTCSlideViewDelegate <NSObject>

- (void)startCapture;

- (void)stopCapture;

- (void)startPush:(NSString *)url;

@end

@interface RTCSlideView : NSView
@property (nonatomic, weak) id<RTCSlideViewDelegate> delegate;
@property (nonatomic, copy) void (^startCapture)(void);
@property (nonatomic, copy) void (^stopCapture)(void);

@end

NS_ASSUME_NONNULL_END
