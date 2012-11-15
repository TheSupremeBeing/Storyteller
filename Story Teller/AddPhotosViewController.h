//
//  AddPhotosViewController.h
//  Story Teller
//
//  Created by Logan Isitt on 4/17/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "iAd/ADBannerView.h"
#import "Pages.h"
//#import "GADBannerViewDelegate.h"

@interface AddPhotosViewController : UIViewController 
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, UIPopoverControllerDelegate, ADBannerViewDelegate>
{
    int height;
    int width;
    int imageWidth;
    
    BOOL isRecording;
    BOOL didRecord;
    BOOL didPick;
    
    BOOL iadBannerLoaded;
    BOOL admobBannerLoaded;
}
@property (strong, nonatomic) UILabel *myTitle;
@property (strong, nonatomic) UILabel *myPhotoLabel;
@property (strong, nonatomic) UILabel *myRecordLabel;
@property (strong, nonatomic) UIButton *myRecordStopButton;
@property (strong, nonatomic) UIButton *myPlayButton;
@property (strong, nonatomic) UIButton *myTakeButton;
@property (strong, nonatomic) UIButton *myLibraryButton;
@property (strong, nonatomic) UIButton *myBackButton;
@property (strong, nonatomic) UIButton *mySaveButton;
@property (strong, nonatomic) UIImageView *myImageView;

@property (strong, nonatomic) UIImagePickerController *myPicker;
@property (strong, nonatomic) UIImage *myImage;
@property (strong, nonatomic) UIImage *myThumb;
@property (nonatomic) IBOutlet UIPopoverController *myPopUp;

@property (strong, nonatomic) NSURL *myPath;
@property (strong, nonatomic) AVAudioRecorder *myRecorder;
@property (strong, nonatomic) AVAudioSession *mySession;
@property (strong, nonatomic) AVAudioPlayer *myPlayer;

@property (nonatomic) NSInteger selectedPath;
@property NSString *storyName;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL debug;
@property int pages;

-(IBAction) popBackView:(id)sender;
-(IBAction) takePhoto:(id)sender;
-(IBAction) selectImage:(id)sender;
-(IBAction) record:(id)sender;
-(IBAction) play:(id)sender;
-(IBAction) addPhoto:(id)sender;

@end