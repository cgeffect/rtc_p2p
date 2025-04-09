//
//  main.m
//  rtc_macos
//
//  Created by Jason on 2025/3/9.
//

#import <Cocoa/Cocoa.h>
#import "RTCAppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [NSApplication sharedApplication];
        RTCAppDelegate* delegate = [[RTCAppDelegate alloc] init];
        [NSApp setDelegate:delegate];
        [NSApp run];
    }
//    return NSApplicationMain(argc, argv);
}
