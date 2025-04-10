//
//  RTCAppDelegate.m
//  RTCApp
//
//  Created by Jason on 2024/4/23.
//

#import "RTCAppDelegate.h"
#import "RTCViewController.h"
#import <WebRTC/WebRTC.h>

@interface RTCAppDelegate () <NSWindowDelegate>

@end
@implementation RTCAppDelegate
{
    RTCViewController* _viewController;
    NSWindow* _window;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
  RTCInitializeSSL();
  NSScreen* screen = [NSScreen mainScreen];
  NSRect visibleRect = [screen visibleFrame];
  NSRect windowRect = NSMakeRect(NSMidX(visibleRect),
                                 NSMidY(visibleRect),
                                 1000,
                                 800);
  NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
  _window = [[NSWindow alloc] initWithContentRect:windowRect
                                        styleMask:styleMask
                                          backing:NSBackingStoreBuffered
                                            defer:NO];
  _window.delegate = self;
  [_window makeKeyAndOrderFront:self];
  [_window makeMainWindow];
  _viewController = [[RTCViewController alloc] initWithNibName:nil
                                                           bundle:nil];
  [_window setContentView:[_viewController view]];
}

#pragma mark - NSWindow

- (void)windowWillClose:(NSNotification*)notification {
  [_viewController windowWillClose:notification];
  RTCCleanupSSL();
  [NSApp terminate:self];
}

@end
