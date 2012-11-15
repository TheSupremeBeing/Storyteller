//
//  DataViewController.m
//  Pages
//
//  Created by Logan Isitt on 5/22/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import "DataViewController.h"

@implementation DataViewController
@synthesize dataObject, audioObject, myPlayer, mySession;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(UIImageView *)self.view setImage: [UIImage imageWithContentsOfFile:dataObject]];
    
    mySession = [AVAudioSession sharedInstance];
    [mySession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [mySession setActive:YES error:nil];
    myPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioObject error:nil];
}
- (IBAction) playAudio:(id)sender
{
    [myPlayer play];
}

-(BOOL) isPlaying
{
    return [myPlayer isPlaying];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [myPlayer stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
