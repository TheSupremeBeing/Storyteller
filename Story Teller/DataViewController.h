//
//  DataViewController.h
//  Pages
//
//  Created by Logan Isitt on 5/22/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface DataViewController : UIViewController
<AVAudioRecorderDelegate>
@property (strong, nonatomic) id dataObject;
@property (strong, nonatomic) id audioObject;
@property (strong, nonatomic) AVAudioSession *mySession;
@property (strong, nonatomic) AVAudioPlayer *myPlayer;

- (IBAction) playAudio:(id)sender;
- (BOOL) isPlaying;
@end
