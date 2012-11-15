//
//  AddAlbumViewController.h
//  Story Teller
//
//  Created by Logan Isitt on 4/17/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "iAd/ADBannerView.h"
//#import "GADBannerViewDelegate.h"

#import "Story.h"

@interface AddAlbumViewController : UIViewController 
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UITextViewDelegate, ADBannerViewDelegate, UIScrollViewDelegate>
{
    int width;
    int height;
    int imageWidth;
    
    BOOL iadBannerLoaded;
    BOOL admobBannerLoaded;
}
@property (strong, nonatomic) UILabel *myTitle;
@property (strong, nonatomic) UILabel *myNamePrompt;
@property (strong, nonatomic) UILabel *myPhotoPrompt;
@property (strong, nonatomic) UITextView *myAlbumNameInput;
@property (strong, nonatomic) UIButton *myTakeButton;
@property (strong, nonatomic) UIButton *myLibraryButton;
@property (strong, nonatomic) UIButton *myBackButton;
@property (strong, nonatomic) UIButton *mySaveButton;
@property (strong, nonatomic) UIImageView * mySelectedImage;
@property (strong, nonatomic) UIImageView * myScaleImage;
@property (strong, nonatomic) UIScrollView *myImageResizer;
@property (strong, nonatomic) ADBannerView *myiAdsBanner;
//@property (strong, nonatomic) GADBannerView *myAdmobBanner;

@property (nonatomic) IBOutlet UIImagePickerController *myPicker;
@property (nonatomic) IBOutlet UIImage *myImage;
@property (nonatomic) IBOutlet UIPopoverController *myPopUp;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL debug;

- (IBAction) selectImage: (id)sender;
- (IBAction) takePhoto:(id)sender;

@end