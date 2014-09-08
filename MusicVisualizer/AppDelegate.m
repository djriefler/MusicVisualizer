//
//  AppDelegate.m
//  MusicVisualizer
//
//  Created by Duncan Riefler on 7/31/14.
//  Copyright (c) 2014 Bb. All rights reserved.
//

#import "AppDelegate.h"
#import "DJRootViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) DJRootViewController * rvc;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    CGRect bigFrame = CGRectMake(100, 200, 1200, 1000);
    [self.window setFrame:NSRectFromCGRect(bigFrame) display:YES];
//    [((NSView *)self.window.contentView) setFrame:bigFrame]
    self.rvc = [[DJRootViewController alloc] initWithNibName:@"DJRootViewController" bundle:nil];
    
    [self.window.contentView addSubview:self.rvc.view];
    self.rvc.view.frame = CGRectMake(0, 0, 1200, 1000);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
