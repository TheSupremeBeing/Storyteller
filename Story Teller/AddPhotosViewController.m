//
//  AddPhotosViewController.m
//  Story Teller
//
//  Created by Logan Isitt on 4/17/12.
//  Copyright (c) 2012 ME. All rights reserved.
//
#import "AddPhotosViewController.h"
#import "UIImageExtras.h"
//#import "GADBannerView.h"

#define size24  [NSLocalizedString(@"24", nil) intValue]
#define size40  [NSLocalizedString(@"40", nil) intValue]  
#define size55  [NSLocalizedString(@"55", nil) intValue]
#define size80  [NSLocalizedString(@"80", nil) intValue]

@implementation AddPhotosViewController
@synthesize pages, storyName, selectedPath;
@synthesize myThumb, myImage, myPicker, myImageView, myPopUp, myTakeButton, myLibraryButton; // <-- Image Components 
@synthesize mySession, myRecorder, myPlayer, myPath, myRecordStopButton, myPlayButton; // <- Recording Components
@synthesize fetchedResultsController, managedObjectContext, debug; // <-- Core Date Components
@synthesize myTitle, myPhotoLabel, myRecordLabel, myBackButton, mySaveButton; // <-- Labels, buttons and more

- (void)viewDidLoad
{
    [super viewDidLoad];
    myImage     = nil;
    isRecording = NO;
    didPick     = NO;
    didRecord   = NO;
    width       = self.view.frame.size.width;
    height      = self.view.frame.size.height;
        
    [self drawTitle];
    [self drawPhotoLabel];
    [self drawRecordLabel];
    [self drawTakeButton];
    [self drawLibraryButton];
    [self drawRecordButton];
    [self drawPlayButton];
    [self drawBackButton];
    [self drawSaveButton];
    [self drawSelectedImage];
    
    mySession = [AVAudioSession sharedInstance];
    [mySession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [mySession setActive:YES error:nil];
    
    myPath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp"]];
    
    myRecorder = [[AVAudioRecorder alloc] initWithURL:myPath settings:nil error:nil];
    [myRecorder setDelegate:self];
    [myRecorder prepareToRecord];
    
    myPicker = [[UIImagePickerController alloc] init];
    [myPicker setDelegate:self];
    [myPicker shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
     {
        myPopUp = [[UIPopoverController alloc] initWithContentViewController:myPicker];
        myPopUp.delegate = self;
     }
}

- (void)viewDidUnload
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:myPath error:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

-(IBAction) popBackView:(id)sender
{
    [myPlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(IBAction) takePhoto:(id)sender 
{
    [myPlayer stop];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
     {
        myPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
     } 
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
     {
        [self presentModalViewController:myPicker animated:YES];
     } 
    else 
     {
        [myPopUp presentPopoverFromRect:myTakeButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
     }    
}
-(IBAction) selectImage:(id)sender 
{
    [myPlayer stop];
    myPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
     {
        [self presentModalViewController:myPicker animated:YES];
     } 
    else 
     {
        [myPopUp presentPopoverFromRect:myLibraryButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
     }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker 
{    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
     {
        [self dismissModalViewControllerAnimated:YES];
     } 
    else 
     {
        [myPopUp dismissPopoverAnimated:YES];
     }
}

- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
     {
        [self dismissModalViewControllerAnimated:YES];
     } 
    else 
     {
        [myPopUp dismissPopoverAnimated:YES];
     }
    myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    int selectedWidth = myImage.size.width > 1000 ? 1000 : myImage.size.width;
    myImage = [myImage imageByScalingAndCroppingForSize:CGSizeMake(selectedWidth, selectedWidth * 1.5)];
    myThumb = [myImage imageByScalingAndCroppingForSize:CGSizeMake(150, 225)];

    [myImageView setContentMode:UIViewContentModeScaleAspectFit];
    [myImageView setImage:myImage];
    didPick = YES;
}

-(IBAction) record:(id)sender
{
    if (!isRecording) 
    {
       [myPlayer stop];
       [mySession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
       isRecording = YES;
       [myRecordStopButton setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
       [myPlayButton setHidden:YES];
       [myRecorder record];
    }
    else
    {
       isRecording = NO;
       [myRecordStopButton setTitle:NSLocalizedString(@"Record", nil) forState:UIControlStateNormal];
       [myPlayButton setHidden:NO];
       [myRecorder stop];
            
       [mySession setCategory:AVAudioSessionCategoryPlayback error:nil];
       myPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:myPath error:nil];
       [myPlayer play];
       didRecord = YES;
     }
}

-(IBAction) play:(id)sender
{
    [mySession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [myPlayer play];
}

-(IBAction) addPhoto:(id)sender
{
    [myPlayer stop];
    if (didPick && didRecord)
     {        
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
         NSString *documentPath = [paths objectAtIndex:0];
         
         Pages *myPage = [NSEntityDescription insertNewObjectForEntityForName:@"Pages" inManagedObjectContext:managedObjectContext];
         myPage.story = storyName;
         NSString *timestamp = [NSString stringWithFormat:@"%.00f", [NSDate timeIntervalSinceReferenceDate]];
         NSString *thumbFile = [NSString stringWithFormat:@"thumb%@%@.jpeg", storyName,timestamp];
         NSString *imageFile = [NSString stringWithFormat:@"%@%@.jpeg", storyName, timestamp];
         NSString *clipFile = [NSString stringWithFormat:@"%@%@.caf",storyName, timestamp];
         
         myPage.thumb  = [documentPath stringByAppendingPathComponent:thumbFile];
         myPage.paths   = [documentPath stringByAppendingPathComponent:imageFile];
         myPage.clips   = [documentPath stringByAppendingPathComponent:clipFile];
         [self.managedObjectContext save:nil];

         NSData *thumb  = [NSData dataWithData:UIImageJPEGRepresentation(myThumb, 1)];
         NSData *image  = [NSData dataWithData:UIImageJPEGRepresentation(myImage, 1)];
         NSData *clip   = [NSData dataWithContentsOfURL:myPath];
         [[NSFileManager defaultManager] createFileAtPath:myPage.thumb contents:nil attributes:nil];
         [[NSFileManager defaultManager] createFileAtPath:myPage.paths contents:nil attributes:nil];
         [[NSFileManager defaultManager] createFileAtPath:myPage.clips contents:nil attributes:nil];
         [thumb writeToFile:myPage.thumb atomically:YES];
         [image writeToFile:myPage.paths atomically:YES];
         [clip writeToFile:myPage.clips atomically:YES];
         
         didPick = NO;
         didRecord = NO;
         [myImageView setImage:nil];
         [myPlayButton setHidden:YES];
    }
}

// Beginning of Core Data
- (void)setupFetchedResultsController:(NSString *) entityName
{    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self performFetch];
}

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.fetchedResultsController.fetchRequest.predicate) 
         {
            if (self.debug) NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
         } else {
             if (self.debug) NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
         }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
    } else {
        if (self.debug) NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
}
// End of Core Data
// Beginning of Layout
-(void) drawTitle
{
    myTitle = [[UILabel alloc] init];
    [myTitle setFrame:CGRectMake(0, 0, width, height*.20)];
    [myTitle setBackgroundColor:[UIColor clearColor]];
    [myTitle setText:NSLocalizedString(@"Add Pages", nil) ];
    [myTitle setTextAlignment:UITextAlignmentCenter];
    [myTitle setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 50 : 120]];
    [myTitle setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:myTitle];
}

-(void) drawPhotoLabel
{
    myPhotoLabel = [[UILabel alloc] init];
    [myPhotoLabel setFrame:CGRectMake(0, height*.1, width, height*.20)];
    [myPhotoLabel setBackgroundColor:[UIColor clearColor]];
    [myPhotoLabel setText:NSLocalizedString(@"Select Photo", nil)];
    [myPhotoLabel setTextAlignment:UITextAlignmentCenter];
    [myPhotoLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 30 : 60]];
    [myPhotoLabel setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:myPhotoLabel];
}

-(void) drawRecordLabel
{
    myRecordLabel = [[UILabel alloc] init];
    [myRecordLabel setFrame:CGRectMake(0, height*.57, width, height*.20)];
    [myRecordLabel setBackgroundColor:[UIColor clearColor]];
    [myRecordLabel setText:NSLocalizedString(@"Page Recording", nil)];
    [myRecordLabel setTextAlignment:UITextAlignmentCenter];
    [myRecordLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 30 : 60]];
    [myRecordLabel setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:myRecordLabel];
}

-(void) drawTakeButton
{
    myTakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myTakeButton setFrame:CGRectMake(width*.0, height*.23, width/2, height*.12)];
    [myTakeButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myTakeButton setBackgroundImage:button forState:UIControlStateNormal];
    [myTakeButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myTakeButton setTitle:NSLocalizedString(@"Take Photo", nil) forState:UIControlStateNormal];
    [myTakeButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size24 : size55;
    [myTakeButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myTakeButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myTakeButton];
}

-(void) drawLibraryButton
{
    myLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myLibraryButton setFrame:CGRectMake(0, height*.38, width/2, height*.12)];
    [myLibraryButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myLibraryButton setBackgroundImage:button forState:UIControlStateNormal];
    [myLibraryButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myLibraryButton setTitle:NSLocalizedString(@"From Library", nil) forState:UIControlStateNormal];
    [myLibraryButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size24 : size55;
    [myLibraryButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myLibraryButton addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myLibraryButton];
}

-(void) drawRecordButton
{
    myRecordStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myRecordStopButton setFrame:CGRectMake(width*.0, height*.70, width/2, height*.12)];
    [myRecordStopButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myRecordStopButton setBackgroundImage:button forState:UIControlStateNormal];
    [myRecordStopButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myRecordStopButton setTitle:NSLocalizedString(@"Record", nil) forState:UIControlStateNormal];
    [myRecordStopButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size24 : size55;
    [myRecordStopButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myRecordStopButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myRecordStopButton];
}

-(void) drawPlayButton
{
    myPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myPlayButton setFrame:CGRectMake(width/2, height*.70, width/2, height*.12)];
    [myPlayButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myPlayButton setBackgroundImage:button forState:UIControlStateNormal];
    [myPlayButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myPlayButton setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
    [myPlayButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size24 : size55;
    [myPlayButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myPlayButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [myPlayButton setHidden:YES];
    [self.view addSubview:myPlayButton];
}

-(void) drawBackButton
{
    myBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myBackButton setFrame:CGRectMake(0, height*.85, width*.33, height*.15)];
    [myBackButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myBackButton setBackgroundImage:button forState:UIControlStateNormal];
    [myBackButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myBackButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [myBackButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size40 : size80;
    [myBackButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myBackButton addTarget:self action:@selector(popBackView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myBackButton];
}

-(void) drawSaveButton
{
    mySaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mySaveButton setFrame:CGRectMake(width*.67, height*.85, width*.33, height*.15)];
    [mySaveButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [mySaveButton setBackgroundImage:button forState:UIControlStateNormal];
    [mySaveButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [mySaveButton setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    [mySaveButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size40 : size80;
    [mySaveButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [mySaveButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mySaveButton];
}

-(void) drawSelectedImage
{
    myImageView = [[UIImageView alloc] init];
    imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 125 : 270;
    [myImageView setFrame:CGRectMake(width*.55, height *.23, imageWidth, imageWidth*1.5)];
    [myImageView setContentMode:UIViewContentModeScaleAspectFill];
    [myImageView.layer setBorderWidth:2];
    [myImageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [myImageView.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self.view addSubview:myImageView];
}

//-(void) drawAdmobBanner
//{
//    CGPoint origin = CGPointMake(0.0, self.view.frame.size.height);
//    myAdmobBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:origin];
//    myAdmobBanner.adUnitID = @"a150243023c00f9";
//    myAdmobBanner.delegate = self;
//    [myAdmobBanner setRootViewController:self];
//    [self.view addSubview:myAdmobBanner];
//}
////End Of Layout
////Beginning of Ad Banner methods
//- (void)bannerViewDidLoadAd:(ADBannerView *)banner
//{
//    NSLog(@"iAd banner Loaded");
//    iadBannerLoaded = YES;
//    [self adjustBannerView];
//    [myiAdsBanner setFrame:CGRectMake(0, height - [self getAdBannerHeight], width, myAdmobBanner.frame.size.height)];
//    [myAdmobBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
//}
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
//{
//    NSLog(@"iAd banner Failed");
//    iadBannerLoaded = NO;
//    [self adjustBannerView];
//    [myiAdsBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
//    [myAdmobBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
//    [myAdmobBanner loadRequest:[GADRequest request]];
//}
//
//- (void)adViewDidReceiveAd:(GADBannerView *)adView 
//{
//    NSLog(@"Admob banner Loaded");
//    admobBannerLoaded = YES;
//    [self adjustBannerView];
//    [myAdmobBanner setFrame:CGRectMake(0, height - [self getAdBannerHeight], width, myAdmobBanner.frame.size.height)];
//    [myiAdsBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
//}
//- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error 
//{
//    NSLog(@"Admob banner Failed w/error: %@", [error localizedFailureReason]);
//    admobBannerLoaded = NO;
//    [self adjustBannerView];
//    [myiAdsBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
//    [myAdmobBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
//}
//
//- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
//{
//    return YES;
//}
//
//- (void)bannerViewActionDidFinish:(ADBannerView *)banner
//{
//    
//}
//
//- (void) adjustBannerView
//{
//    CGRect backButtonRect   = CGRectMake(0, height*.85, width*.33, height*.15);
//    CGRect saveButtonRect   = CGRectMake(width*.67, height*.85, width*.33, height*.15);
//    CGRect recordRect       = CGRectMake(0, height*.70, width/2, height*.12);
//    CGRect playRect         = CGRectMake(width/2, height*.70, width/2, height*.12);
//    CGRect labelRect        = CGRectMake(0, height*.57, width, height*.20);
//    
//    imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 90 : 230;
//    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) 
//     {
//        imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 55 : 150;
//     }
//    
//    if(iadBannerLoaded || admobBannerLoaded)
//     {
//        backButtonRect.origin.y -= [self getAdBannerHeight];
//        saveButtonRect.origin.y -= [self getAdBannerHeight];
//        recordRect.origin.y -= [self getAdBannerHeight];
//        playRect.origin.y -= [self getAdBannerHeight];    
//        labelRect.origin.y -= [self getAdBannerHeight];
//        
//        [UIView animateWithDuration:0.5 animations:^
//         {
//            [myBackButton   setFrame:backButtonRect];
//            [mySaveButton   setFrame:saveButtonRect];
//            [myRecordStopButton setFrame:recordRect];
//            [myPlayButton   setFrame:playRect];
//            [myRecordLabel  setFrame:labelRect];
//            [myImageView setFrame:CGRectMake(width*.55, height *.23, imageWidth, imageWidth*1.5)];
//         }];
//     }
//}
//
//-(NSInteger) getAdBannerHeight
//{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) 
//     {
//        return myiAdsBanner.frame.size.height;
//     }
//    return 66;
//}
// End of Ad Banner methods
// Beginning of Orientation methods
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    width   = self.view.frame.size.width;
    height  = self.view.frame.size.height;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
     {
        [myPopUp dismissPopoverAnimated:YES];
     }

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
     {
        imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 125 : 270;
//        self.myiAdsBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
//        self.myAdmobBanner.adSize = kGADAdSizeSmartBannerPortrait;
     }
    else
     {
        imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 80 : 200;
//        self.myiAdsBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//        self.myAdmobBanner.adSize = kGADAdSizeSmartBannerLandscape;
     }
    
    if (iadBannerLoaded) 
     {
//        [myiAdsBanner setFrame:CGRectMake(0, height - [self getAdBannerHeight], width, myAdmobBanner.frame.size.height)];
//        [myAdmobBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
     }
    if (admobBannerLoaded) 
     {
//        [myAdmobBanner setFrame:CGRectMake(0, height - [self getAdBannerHeight], width, myAdmobBanner.frame.size.height)];
//        [myiAdsBanner setFrame:CGRectMake(0, height, width, myAdmobBanner.frame.size.height)];
     }
    
    [myTitle            setFrame:CGRectMake(0, 0, width, height*.20)];
    [myPhotoLabel       setFrame:CGRectMake(0, height*.1, width, height*.20)];
    [myRecordLabel      setFrame:CGRectMake(0, height*.57, width, height*.20)];
    [myTakeButton       setFrame:CGRectMake(width*.0, height*.23, width/2, height*.12)];
    [myLibraryButton    setFrame:CGRectMake(0, height*.38, width/2, height*.12)];
    [myRecordStopButton setFrame:CGRectMake(width*.0, height*.70, width/2, height*.12)];
    [myPlayButton       setFrame:CGRectMake(width/2, height*.70, width/2, height*.12)];
    [myBackButton       setFrame:CGRectMake(0, height*.85, width*.33, height*.15)];
    [mySaveButton       setFrame:CGRectMake(width*.67, height*.85, width*.33, height*.15)];
    [myImageView        setFrame:CGRectMake(width*.55, height *.23, imageWidth, imageWidth*1.5)];
    
//    [self adjustBannerView];
}
// End of Orientation methods
@end