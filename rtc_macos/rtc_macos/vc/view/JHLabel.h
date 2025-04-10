//
//  JHLabel.h
//  JHLabel
//
//  Created by GJH on 2019/3/5.
//  Copyright © 2019 GJH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

IB_DESIGNABLE
@interface JHLabel : NSView

@property(nonatomic, copy)   IBInspectable NSString*           text;
@property(nonatomic, copy)                 NSAttributedString* attributedText;
@property(nonatomic, retain)               NSFont*             font;
@property(nonatomic, retain) IBInspectable NSColor*            textColor;
@property(nonatomic, retain) IBInspectable NSColor*            backgroundColor;
@property(nonatomic, assign) IBInspectable NSInteger           numberOfLines;
@property(nonatomic, assign)               NSTextAlignment     textAlignment;
@property(nonatomic, assign)               NSLineBreakMode     lineBreakMode;
@property(nonatomic, assign) IBInspectable CGFloat             preferredMaxLayoutWidth;

- (instancetype)init;
- (instancetype)initWithFrame:(NSRect)frameRect NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder*)coder NS_DESIGNATED_INITIALIZER;

@end
