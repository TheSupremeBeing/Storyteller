//
//  RootViewController.h
//  Pages
//
//  Created by Logan Isitt on 5/22/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelController.h"
#import "DataViewController.h"
#import <CoreData/CoreData.h>
#import "QuartzCore/QuartzCore.h"
#import "iAd/ADBannerView.h"
//#import "GADBannerViewDelegate.h"

@interface PhotoViewController : UIViewController 
<UIPageViewControllerDelegate, UIScrollViewDelegate, ADBannerViewDelegate>
{
    int width;
    int height;
    
    BOOL iadBannerLoaded;
    BOOL admobBannerLoaded;
}
@property (strong, nonatomic) UIScrollView *myPageView;
@property (strong, nonatomic) UIButton *myBackButton;
@property (strong, nonatomic) UIButton *myPlayButton;
@property (strong, nonatomic) ADBannerView *myiAdsBanner;
//@property (strong, nonatomic) GADBannerView *myAdmobBanner;

@property (readonly, strong, nonatomic) ModelController *myModelController;
@property (strong, nonatomic) UIPageViewController *myPagesViewController;
@property (strong, nonatomic) NSMutableArray *myPhotosArray;
@property (strong, nonatomic) NSMutableArray *myClipsArray;
@property (nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL debug;

-(IBAction) popView:(id)sender;
-(IBAction) playAudio:(id)sender;

@end
