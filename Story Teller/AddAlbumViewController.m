//
//  AddAlbumViewController.m
//  Story Teller
//
//  Created by Logan Isitt on 4/17/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import "AddAlbumViewController.h"
#import "UIImageExtras.h"
//#import "GADBannerView.h"

#define size24  [NSLocalizedString(@"24", nil) intValue]
#define size40  [NSLocalizedString(@"40", nil) intValue]  
#define size55  [NSLocalizedString(@"55", nil) intValue]
#define size80  [NSLocalizedString(@"80", nil) intValue]

@implementation AddAlbumViewController
@synthesize mySelectedImage, myPicker, myAlbumNameInput, myImage, myPopUp, myImageResizer;
@synthesize fetchedResultsController, managedObjectContext, debug;
@synthesize myTitle, myNamePrompt, myPhotoPrompt, myBackButton, mySaveButton, myTakeButton, myLibraryButton, myiAdsBanner, myScaleImage;

- (void)viewDidLoad
{
    width   = self.view.frame.size.width;
    height  = self.view.frame.size.height;

    myPicker = [[UIImagePickerController alloc] init];
    myPicker.delegate = self;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
     {
        myPopUp = [[UIPopoverController alloc] initWithContentViewController:myPicker];
        myPopUp.delegate = self;
     } 

    myAlbumNameInput.inputView.backgroundColor = [UIColor brownColor];
    
    [self drawTitle];
    [self drawNamePrompt];
    [self drawAlbumName];
    [self drawPhotoPrompt];
    [self drawBackButton];
    [self drawSaveButton];
    [self drawTakeButton];
    [self drawLibraryButton];
    [self drawSelectedImage];
    [self drawScrollView];
    
    NSString *key = @"Block Ads";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key] == NO) 
     {
//        [self drawiAdBanner];
//        [self drawAdmobBanner];
     }
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    myPicker = nil;
    myImage = nil;
    mySelectedImage = nil;
    myAlbumNameInput = nil;
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

-(IBAction) popBackView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Beginning of Photos
-(IBAction) saveAlbum:(id)sender
{    
    if (myAlbumNameInput.text.length > 0)
     {
        float scale = 1.0f/myImageResizer.zoomScale;
        
        CGRect visibleRect;
        visibleRect.origin.x = myImageResizer.contentOffset.x * scale;
        visibleRect.origin.y = myImageResizer.contentOffset.y * scale;
        visibleRect.size.width = myImageResizer.bounds.size.width * scale;
        visibleRect.size.height = myImageResizer.bounds.size.height * scale;
        
        
        [self setupFetchedResultsController:@"Story"];
        Story *myStory = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:managedObjectContext];
        myStory.name = myAlbumNameInput.text;
        myStory.date = [NSDate timeIntervalSinceReferenceDate];
        myStory.cover = [self cropImage:myImage withRect:visibleRect];
        [self.managedObjectContext save:nil];
        [self.navigationController popViewControllerAnimated:YES];
     }
}

-(UIImage*) cropImage:(UIImage*) srcImage withRect:(CGRect) rect
{
    CGImageRef cr = CGImageCreateWithImageInRect([srcImage CGImage], rect);
    UIImage* cropped = [[UIImage alloc] initWithCGImage:cr];
    CGImageRelease(cr);
    return cropped;
}

-(IBAction) takePhoto:(id)sender 
{
    [myAlbumNameInput resignFirstResponder];
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
        CGRect bound = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 
                CGRectMake(width/2, height*.45, 0, 0) : CGRectMake(width/2, height/5, 0, 0);
        [myPopUp presentPopoverFromRect:bound inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
     }    
}
-(IBAction) selectImage:(id)sender 
{
    [myAlbumNameInput resignFirstResponder];
    myPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
     {
        [self presentModalViewController:myPicker animated:YES];
     } 
    else 
     {
        CGRect bound = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 
                CGRectMake(width/2, height*.45, 0, 0) : CGRectMake(width/2, height/5, 0, 0);
        [myPopUp presentPopoverFromRect:bound inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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
    for (UIView *v in [myImageResizer subviews])
     {
        [v removeFromSuperview];
     }
    
    myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
     {
        [self dismissModalViewControllerAnimated:YES];
     } 
    else 
     {
        [myPopUp dismissPopoverAnimated:YES];
     }
    myScaleImage = [[UIImageView alloc] initWithImage:myImage];
    [myImageResizer addSubview:myScaleImage];
    [myImageResizer setContentSize:myScaleImage.frame.size];
    myImageResizer.zoomScale = .10;
    CGPoint centerOffset = CGPointMake(myImageResizer.contentSize.width/2 - myImageResizer.frame.size.width/2, myImageResizer.contentSize.height/2 - myImageResizer.frame.size.height/2);
    [myImageResizer setContentOffset:centerOffset animated: YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return myScaleImage;
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

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

// Beginning of Layout
-(void) drawTitle
{
    myTitle = [[UILabel alloc] init];
    [myTitle setFrame:CGRectMake(0, 0, width, height*.20)];
    [myTitle setBackgroundColor:[UIColor clearColor]];
    [myTitle setText:NSLocalizedString(@"Create Story", nil)];
    [myTitle setTextAlignment:UITextAlignmentCenter];
    [myTitle setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 50 : 120]];
    [myTitle setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:myTitle];
}

-(void) drawNamePrompt
{
    myNamePrompt = [[UILabel alloc] init];
    [myNamePrompt setFrame:CGRectMake(0, height*.1, width, height*.20)];
    [myNamePrompt setBackgroundColor:[UIColor clearColor]];
    [myNamePrompt setText:NSLocalizedString(@"Story Name", nil)];
    [myNamePrompt setTextAlignment:UITextAlignmentCenter];
    [myNamePrompt setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 30 : 60]];
    [myNamePrompt setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:myNamePrompt];
}

-(void) drawPhotoPrompt
{
    myPhotoPrompt = [[UILabel alloc] init];
    [myPhotoPrompt setFrame:CGRectMake(0, height*.25, width, height*.20)];
    [myPhotoPrompt setBackgroundColor:[UIColor clearColor]];
    [myPhotoPrompt setText:NSLocalizedString(@"Story Cover", nil)];
    [myPhotoPrompt setTextAlignment:UITextAlignmentCenter];
    [myPhotoPrompt setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 30 : 60]];
    [myPhotoPrompt setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:myPhotoPrompt];
}

-(void) drawAlbumName
{
    myAlbumNameInput = [[UITextView alloc] init];
    [myAlbumNameInput setFrame:CGRectMake(width*.1, height*.25, width*.8, height*.05)];
    [myAlbumNameInput setDelegate:self];
    [myAlbumNameInput setBackgroundColor:[UIColor brownColor]];
    [myAlbumNameInput setTextColor:[UIColor blackColor]];
    [myAlbumNameInput setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 18 : 30]]; 
    [myAlbumNameInput setTextAlignment:UITextAlignmentCenter];
    [myAlbumNameInput setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
    
    myAlbumNameInput.layer.cornerRadius = 10;
    myAlbumNameInput.layer.borderColor = [[UIColor blackColor] CGColor];
    myAlbumNameInput.layer.borderWidth = 2;
    
    [self.view addSubview:myAlbumNameInput];
}

-(void) drawTakeButton
{
    myTakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myTakeButton setFrame:CGRectMake(0, height*.38, width/2, height*.12)];
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
    [myLibraryButton setFrame:CGRectMake(width/2, height*.38, width/2, height*.12)];
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
    [mySaveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [mySaveButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size40 : size80;
    [mySaveButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [mySaveButton addTarget:self action:@selector(saveAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mySaveButton];
}

-(void) drawScrollView
{
    myImageResizer = [[UIScrollView alloc] init];
    [myImageResizer setFrame:CGRectMake(width/2 - imageWidth/2, height *.55, imageWidth, imageWidth*.666)];
    [myImageResizer setDelegate:self];
    [myImageResizer setMinimumZoomScale:.10];
    [myImageResizer setMaximumZoomScale:1.0];
    
    [myImageResizer.layer setBorderColor:[UIColor blackColor].CGColor];
    [myImageResizer.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [myImageResizer.layer setBorderWidth:2];
    [self.view addSubview:myImageResizer];
    
}
-(void) drawSelectedImage
{
    mySelectedImage = [[UIImageView alloc] init];
    imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 180 : 360;
    [mySelectedImage setFrame:CGRectMake(width/2 - imageWidth/2, height *.55, imageWidth, imageWidth*.666)];
    [mySelectedImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:mySelectedImage];
}
// Beginning of Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

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
        imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 180 : 360;
     }
    else
     {
        imageWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 160 : 360;
     }
    
    [myTitle            setFrame:CGRectMake(0, 0, width, height*.20)];
    [myNamePrompt       setFrame:CGRectMake(0, height*.1, width, height*.20)];
    [myAlbumNameInput   setFrame:CGRectMake(width*.1, height*.25, width*.8, height*.05)];
    [myPhotoPrompt      setFrame:CGRectMake(0, height*.25, width, height*.20)];
    [mySelectedImage    setFrame:CGRectMake(width/2 - imageWidth/2, height *.6, imageWidth, imageWidth*.666)];
    [myImageResizer     setFrame:CGRectMake(width/2 - imageWidth/2, height *.55, imageWidth, imageWidth*.666)];
    [myTakeButton       setFrame:CGRectMake(0, height*.38, width/2, height*.12)];
    [myLibraryButton    setFrame:CGRectMake(width/2, height*.38, width/2, height*.12)];
    [myBackButton       setFrame:CGRectMake(0, height*.85, width*.33, height*.15)];
    [mySaveButton       setFrame:CGRectMake(width*.67, height*.85, width*.33, height*.15)];
}
// End of Orientation methods
// Beginning of Text View Delegate Methods
- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText 
{
    if ([aText isEqualToString:@"\n"]) 
     {
        [aTextView resignFirstResponder];
        return NO;
     } 
    return YES;
}
// End of Text View Delegate Methods
@end