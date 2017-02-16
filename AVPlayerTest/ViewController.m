//
//  ViewController.m
//  AVPlayerTest
//
//  Created by George Brown on 16.02.17.
//  Copyright © 2017 Serious Cyrus. All rights reserved.
//
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Only one segue
    AVPlayerViewController *vc = (AVPlayerViewController *)segue.destinationViewController;
    NSURL *fileURL = [[NSBundle bundleForClass:self.class] URLForResource:@"SampleVideo_1280x720_10mb" withExtension:@"mp4"];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:fileURL];
    vc.player = [AVPlayer playerWithPlayerItem:playerItem];
}


@end
