//
//  DetailViewController.h
//  Story Teller
//
//  Created by Logan Isitt on 4/8/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "QuartzCore/QuartzCore.h"
#import "iAd/ADBannerView.h"

//#import "GADBannerViewDelegate.h"

#import "AddPhotosViewController.h"
#import "PhotoViewController.h"

#import "Pages.h"

@interface DetailViewController : UIViewController 
<UIScrollViewDelegate, ADBannerViewDelegate>
{
    int width;
    int height;
    
    CGRect galleryRect;
    
    NSInteger selectedBtn;
    BOOL isEditing;
    NSMutableArray *myImages;
    NSMutableArray *myThumbs;
    NSMutableArray *myClips;
    
    BOOL iadBannerLoaded;
    BOOL admobBannerLoaded;
}
@property NSString *storyName;
@property (strong, nonatomic) UILabel *myTitle;
@property (strong, nonatomic) UIScrollView *myImageGallery;
@property (strong, nonatomic) UIButton *myBackButton;
@property (strong, nonatomic) UIButton *myEditButton;
@property (strong, nonatomic) UIButton *myAddButton;

@property (strong, nonatomic) ADBannerView *myiAdsBanner;
//@property (strong, nonatomic) GADBannerView *myAdmobBanner;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL debug;

-(IBAction) editImages:(id)sender;
@end
