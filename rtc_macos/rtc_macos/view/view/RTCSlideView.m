//
//  RTCSlideView.m
//  RTCApp
//
//  Created by Jason on 2024/4/24.
//

#import "RTCSlideView.h"
#import <PureLayout/PureLayout.h>
#import "JHLabel.h"

@interface RTCSlideView ()
{
    NSButton *_startCaptureBtn;
    NSButton *_stopCaptureBtn;
    NSButton *_xrtcBtn;
    NSButton *_rtmpBtn;
    NSButton *_playBtn;
    NSMutableArray <NSButton *>*_btnList;
    
    JHLabel *_xrtcName;
    JHLabel *_uid;
    JHLabel *_cameraName;
    JHLabel *_micName;
    NSTextField *_textField;
    NSTextField *_textUid;
    NSTextField *_textLiveName;

    NSButton *_pushBtn;

}

@end

@implementation RTCSlideView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                
        _btnList = [NSMutableArray array];
        _xrtcBtn = [NSButton buttonWithTitle:@"XRTC" target:self action:@selector(xrtcAct:)];
        [_xrtcBtn setButtonType:NSButtonTypeSwitch];
        [self addSubview:_xrtcBtn];
        [_btnList addObject:_xrtcBtn];
        
        _rtmpBtn = [NSButton buttonWithTitle:@"RTMP" target:self action:@selector(rtmpAct:)];
        [_rtmpBtn setButtonType:NSButtonTypeSwitch];
        [self addSubview:_rtmpBtn];
        [_btnList addObject:_rtmpBtn];
        
        _playBtn = [NSButton buttonWithTitle:@"PLAY" target:self action:@selector(playAct:)];
        [_playBtn setButtonType:NSButtonTypeSwitch];
        [self addSubview:_playBtn];
        [_btnList addObject:_playBtn];
        
        _textField = [[NSTextField alloc] init];
        _textField.maximumNumberOfLines = 1;
        _textField.placeholderString = @"XRTC服务";
        _textField.stringValue = @"www.str2num.com";
        [self addSubview:_textField];
        
        _textUid = [[NSTextField alloc] init];
        _textUid.maximumNumberOfLines = 1;
        _textUid.placeholderString = @"UID";
        _textUid.stringValue = @"1024";
        [self addSubview:_textUid];

        _textLiveName = [[NSTextField alloc] init];
        _textLiveName.maximumNumberOfLines = 1;
        _textLiveName.placeholderString = @"流名称";
        _textLiveName.stringValue = @"xrtc1024";
        [self addSubview:_textLiveName];

        _startCaptureBtn = [NSButton buttonWithTitle:@"启动摄像头" target:self action:@selector(startCapture:)];
        [_startCaptureBtn setBezelStyle:(NSBezelStyleRegularSquare)];
        [_startCaptureBtn setBezelColor:NSColor.systemBlueColor];
        [self addSubview:_startCaptureBtn];

        _stopCaptureBtn = [NSButton buttonWithTitle:@"关闭摄像头" target:self action:@selector(stopCapture:)];
        [_stopCaptureBtn setBezelStyle:(NSBezelStyleRegularSquare)];
        [_stopCaptureBtn setBezelColor:NSColor.systemBlueColor];
        [self addSubview:_stopCaptureBtn];
        
        _pushBtn = [NSButton buttonWithTitle:@"开始推流" target:self action:@selector(pushAct:)];
        [_pushBtn setBezelStyle:(NSBezelStyleRegularSquare)];
        [self addSubview:_pushBtn];


    }
    return self;
}


- (void)rtmpAct:(NSButton *)btn {
    for (NSButton *btn in _btnList) {
        [btn setState:NSControlStateValueOff];
    }
    [btn setState:NSControlStateValueOn];
}

- (void)xrtcAct:(NSButton *)btn {
    for (NSButton *btn in _btnList) {
        [btn setState:NSControlStateValueOff];
    }
    [btn setState:NSControlStateValueOn];

}

- (void)playAct:(NSButton *)btn {
    for (NSButton *btn in _btnList) {
        [btn setState:NSControlStateValueOff];
    }
    [btn setState:NSControlStateValueOn];

}

- (void)startCapture:(NSButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(startCapture)]) {
        [self.delegate startCapture];
    }
}

- (void)stopCapture:(NSButton *)btn {
    
}

- (void)pushAct:(NSButton *)btn {
    if ([btn.title isEqualToString:@"开始推流"]) {
        btn.title = @"结束推流";
    } else {
        btn.title = @"开始推流";
    }
    // xrtc://www.str2num.com/push?uid=xxx&stremaName=xxx
    NSString *url = [NSString stringWithFormat:@"xrtc://%@/push?uid=%@&streamName=%@", _textField.stringValue, _textUid.stringValue, _textLiveName.stringValue];
//    std::string url = "xrtc://" + nbase::UTF16ToUTF8(edit_host_->GetText())
//        + "/push?uid=" + nbase::UTF16ToUTF8(edit_uid_->GetText())
//        + "&streamName=" + nbase::UTF16ToUTF8(edit_stream_name_->GetText());
    
    [self.delegate startPush:url];

}
- (void)updateConstraints {
    [super updateConstraints];
    
    [_xrtcBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10.f];
    [_xrtcBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.f];
    [_xrtcBtn autoSetDimensionsToSize:CGSizeMake(60, 50)];

    [_rtmpBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_xrtcBtn withOffset:0.f];
    [_rtmpBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_xrtcBtn withOffset:0.f];
    [_rtmpBtn autoSetDimensionsToSize:CGSizeMake(60, 50)];

    [_playBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_rtmpBtn withOffset:0.f];
    [_playBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_rtmpBtn withOffset:0.f];
    [_playBtn autoSetDimensionsToSize:CGSizeMake(60, 50)];
    
    [_textField autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10.f];
    [_textField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:100.f];
    [_textField autoSetDimensionsToSize:CGSizeMake(200, 30)];

    [_textUid autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10.f];
    // _textUid的ALEdgeTop 相对与_textField的ALEdgeBottom
    [_textUid autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_textField withOffset:10.f];
    [_textUid autoSetDimensionsToSize:CGSizeMake(200, 30)];

    [_textLiveName autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10.f];
    [_textLiveName autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_textUid withOffset:10.f];
    [_textLiveName autoSetDimensionsToSize:CGSizeMake(200, 30)];

    [_startCaptureBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10.f];
    [_startCaptureBtn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:self.frame.size.height / 2];
    [_startCaptureBtn autoSetDimensionsToSize:CGSizeMake(100, 50)];

    [_stopCaptureBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_startCaptureBtn withOffset:10.f];
    [_stopCaptureBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_startCaptureBtn withOffset:0.f];
    [_stopCaptureBtn autoSetDimensionsToSize:CGSizeMake(100, 50)];

    [_pushBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10.f];
    [_pushBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_startCaptureBtn withOffset:20.f];
    [_pushBtn autoSetDimensionsToSize:CGSizeMake(100, 50)];


}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
