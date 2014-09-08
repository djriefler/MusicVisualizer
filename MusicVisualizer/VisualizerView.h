//
//  VisualizerView.h
//  MusicVisualizer
//
//  Created by Duncan Riefler on 7/31/14.
//  Copyright (c) 2014 Bb. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface VisualizerView : NSView

@property (nonatomic, strong) AVAudioPlayer * audioPlayer;

@end
