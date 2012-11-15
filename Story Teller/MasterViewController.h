//
//  MasterViewController.h
//  Story Teller
//
//  Created by Logan Isitt on 4/8/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "iAd/ADBannerView.h"
//#import "GADBannerViewDelegate.h"

#import "DetailViewController.h"
#import "AddAlbumViewController.h"

#import "Story.h"
#import "Pages.h"

@interface MasterViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>
{
    int width;
    int height;
    
    CGRect titleRectPortrait;
    CGRect titleRectLandscape;
    
    NSInteger selectedPath;
    Story *myStory;
    
    BOOL iadBannerLoaded;
    BOOL admobBannerLoaded;
}
@property (strong, nonatomic) UIImageView *myTitle; // Title of the app
@property (strong, nonatomic) UITableView *myTable; // Table for the books

@property (strong, nonatomic) ADBannerView *myiAdsBanner;
//@property (strong, nonatomic) GADBannerView *myAdmobBanner;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL debug;

@end