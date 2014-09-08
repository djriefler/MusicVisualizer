//
//  DJRootViewController.m
//  MusicVisualizer
//
//  Created by Duncan Riefler on 7/31/14.
//  Copyright (c) 2014 Bb. All rights reserved.
//

#import "DJRootViewController.h"
#import "VisualizerView.h"
#import <Accelerate/Accelerate.h>

@interface DJRootViewController ()
{
    __weak IBOutlet NSButton *playButton;
    AVAudioPlayer * audioPlayer;
    VisualizerView * visualizerView;
}
- (IBAction)playButtonClicked:(id)sender;

@end


@implementation DJRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSString * soundFilePath = [[NSBundle mainBundle] pathForResource:@"Truth" ofType:@"mp3"];
        NSURL * fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
        
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL
                                                             error:nil];
        
        [audioPlayer setMeteringEnabled:YES];
        [audioPlayer setDelegate:self];
        
        // Set up visualizer
        visualizerView = [[VisualizerView alloc] initWithFrame:self.view.frame];
        [visualizerView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
        [self.view addSubview:visualizerView positioned:NSWindowBelow relativeTo:playButton];

        [visualizerView setAudioPlayer:audioPlayer];

        
        [audioPlayer play];
        
    }
    return self;
}

- (void)viewDidLoad {


}

- (void) awakeFromNib {


}


#pragma mark - AVAudioPlayerDelegate Methods

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)completed
{
    if (completed == YES) {
        [playButton setTitle:@"Play"];
    }
}

- (IBAction)playButtonClicked:(id)sender {
    if (audioPlayer.playing == YES) {
        [playButton setTitle:@"Play"];
        [audioPlayer stop];
    }
    else {
        [playButton setTitle:@"Pause"];
        [audioPlayer play];
    }
}
@end