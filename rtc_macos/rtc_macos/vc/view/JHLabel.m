
//
//  JHLabel.m
//  JHLabel
//
//  Created by GJH on 2019/3/5.
//  Copyright © 2019 GJH. All rights reserved.
//

#import "JHLabel.h"

@implementation JHLabel{
    NSRect _drawingRect;
}

#pragma mark -
#pragma mark JHLabel overrides

- (instancetype)init {
    return [self initWithFrame:NSZeroRect];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        // _text, _attributedText and _preferredMaxLayoutWidth are nil/0 by default
        self.font            = self.defaultFont;
        self.textColor       = self.defaultTextColor;
        self.backgroundColor = self.defaultBackgroundColor;
        self.numberOfLines   = 1;
        self.textAlignment   = NSTextAlignmentLeft;
        self.lineBreakMode   = NSLineBreakByTruncatingTail;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)coder {
    if (self = [super initWithCoder:coder]) {
        NSString* text = nil;
        NSAttributedString* attributedText = nil;
        
        if ((text = [coder decodeObjectForKey:@"text"])) {
            self.text = text;
        } else if ((attributedText = [coder decodeObjectForKey:@"attributedText"])) {
            self.attributedText = attributedText;
        }
        
        self.font            = [coder decodeObjectForKey:@"font"];
        self.textColor       = [coder decodeObjectForKey:@"textColor"];
        self.backgroundColor = [coder decodeObjectForKey:@"backgroundColor"];
        self.numberOfLines   = [coder containsValueForKey:@"numberOfLines"] ? [[coder decodeObjectForKey:@"numberOfLines"] integerValue]         : 1;
        self.textAlignment   = [coder containsValueForKey:@"numberOfLines"] ? [[coder decodeObjectForKey:@"textAlignment"] unsignedIntegerValue] : NSTextAlignmentLeft;
        self.lineBreakMode   = [coder containsValueForKey:@"numberOfLines"] ? [[coder decodeObjectForKey:@"lineBreakMode"] unsignedIntegerValue] : NSLineBreakByTruncatingTail;
        
#if CGFLOAT_IS_DOUBLE
        self.preferredMaxLayoutWidth = [[coder decodeObjectForKey:@"preferredMaxLayoutWidth"] doubleValue];
#else
        self.preferredMaxLayoutWidth = [[coder decodeObjectForKey:@"preferredMaxLayoutWidth"] floatValue];
#endif
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    
    NSString* text = nil;
    NSAttributedString* attributedText = nil;
    
    if ((text = self.text)) {
        [aCoder encodeObject:text forKey:@"text"];
    } else if ((attributedText = self.attributedText)) {
        [aCoder encodeObject:attributedText forKey:@"attributedText"];
    }
    
    [aCoder encodeObject:self.font                       forKey:@"font"];
    [aCoder encodeObject:self.textColor                  forKey:@"textColor"];
    [aCoder encodeObject:self.backgroundColor            forKey:@"backgroundColor"];
    [aCoder encodeObject:@(self.numberOfLines)           forKey:@"numberOfLines"];
    [aCoder encodeObject:@(self.textAlignment)           forKey:@"textAlignment"];
    [aCoder encodeObject:@(self.lineBreakMode)           forKey:@"lineBreakMode"];
    [aCoder encodeObject:@(self.preferredMaxLayoutWidth) forKey:@"preferredMaxLayoutWidth"];
}

- (BOOL)isOpaque {
    return self.backgroundColor.alphaComponent == 1.0;
}

- (CGFloat)baselineOffsetFromBottom {
    return self.drawingRect.origin.y;
}

- (NSSize)intrinsicContentSize {
    return self.drawingRect.size;
}

- (void)invalidateIntrinsicContentSize {
    _drawingRect = NSZeroRect;
    [super invalidateIntrinsicContentSize];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = self.bounds;
    NSRect drawRect = {self.drawingRect.origin, bounds.size};
    NSString* text = nil;
    NSAttributedString* attributedText = nil;
    
    [self.backgroundColor setFill];
    NSRectFillUsingOperation(bounds, NSCompositingOperationSourceOver);
    
    if ((text = self.text)) {
        [text drawWithRect:drawRect options:self.drawingOptions attributes:@{
                                                                             NSFontAttributeName            : self.font,
                                                                             NSForegroundColorAttributeName : self.textColor,
                                                                             NSBackgroundColorAttributeName : self.backgroundColor,
                                                                             NSParagraphStyleAttributeName  : self.drawingParagraphStyle,
                                                                             }];
    } else if ((attributedText = self.attributedText)) {
        [attributedText drawWithRect:drawRect options:self.drawingOptions];
    }
}

#pragma mark -
#pragma mark private helper methods

- (NSRect)drawingRect {
    // invalidated by [NSLabel invalidateIntrinsicContentSize]
    
    NSString* text = nil;
    NSAttributedString* attributedText = nil;
    
    if (NSIsEmptyRect(_drawingRect) && ((text = self.text) || (attributedText = self.attributedText))) {
        NSSize size = NSMakeSize(self.preferredMaxLayoutWidth, 0.0);
        
        if (text) {
            _drawingRect = [text boundingRectWithSize:size options:self.drawingOptions attributes:@{
                                                                                                    NSFontAttributeName            : self.font,
                                                                                                    NSForegroundColorAttributeName : self.textColor,
                                                                                                    NSBackgroundColorAttributeName : self.backgroundColor,
                                                                                                    NSParagraphStyleAttributeName  : self.drawingParagraphStyle,
                                                                                                    }];
        } else {
            _drawingRect = [attributedText boundingRectWithSize:size options:self.drawingOptions];
        }
        
        _drawingRect = (NSRect) {
            {
                ceil(-_drawingRect.origin.x),
                ceil(-_drawingRect.origin.y),
            }, {
                ceil(_drawingRect.size.width),
                ceil(_drawingRect.size.height),
            }
        };
    }
    
    return _drawingRect;
}

- (NSStringDrawingOptions)drawingOptions {
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading;
    
    if (self.numberOfLines == 0) {
        options |= NSStringDrawingUsesLineFragmentOrigin;
    }
    
    return options;
}

- (NSParagraphStyle*)drawingParagraphStyle {
    NSMutableParagraphStyle* ps = [NSMutableParagraphStyle new];
    ps.alignment = self.textAlignment;
    
    if (self.numberOfLines) {
        ps.lineBreakMode = self.lineBreakMode;
    }
    
    return ps;
}

- (NSFont*)defaultFont {
    return [NSFont labelFontOfSize:12.0];
}

- (NSColor*)defaultTextColor {
    return [NSColor blackColor];
}

- (NSColor*)defaultBackgroundColor {
    return [NSColor windowBackgroundColor];
}

#pragma mark -
#pragma mark setters which invalidate the view

- (void)setText:(NSString*)text {
    _text = [text copy];
    _attributedText = nil;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setAttributedText:(NSAttributedString*)attributedText {
    _text = nil;
    _attributedText = [attributedText copy];
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setFont:(NSFont*)font {
    _font = font ? font : self.defaultFont;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setTextColor:(NSColor*)textColor {
    _textColor = textColor ? textColor : self.defaultTextColor;
    [self setNeedsDisplay:YES];
}

- (void)setBackgroundColor:(NSColor*)backgroundColor {
    _backgroundColor = backgroundColor ? backgroundColor : self.defaultBackgroundColor;
    [self setNeedsDisplay:YES];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    _lineBreakMode = lineBreakMode;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay:YES];
    
}


@end
