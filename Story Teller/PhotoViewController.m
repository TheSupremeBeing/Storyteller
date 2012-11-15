//
//  RootViewController.m
//  Pages
//
//  Created by Logan Isitt on 5/22/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import "PhotoViewController.h"
//#import "GADBannerView.h"

#define size40  [NSLocalizedString(@"40", nil) intValue]  
#define size80  [NSLocalizedString(@"80", nil) intValue]

@implementation PhotoViewController
@synthesize myPageView, myBackButton, myPlayButton, myiAdsBanner;
@synthesize myPagesViewController,myModelController;
@synthesize myPhotosArray, selectedIndex, myClipsArray;
@synthesize fetchedResultsController, managedObjectContext, debug;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    width   = self.view.frame.size.width;
    height  = self.view.frame.size.height;
    
    [self drawBackButton];
    [self drawPlayButton];
    [self drawPageView];
    
    if ([myPhotosArray count] % 2 == 1) 
     {
        NSURL *blankUrl = [NSURL URLWithString:@"null"];
        [myClipsArray addObject:blankUrl];
        [myPhotosArray addObject:@""];
     }

    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) 
     {
        self.myPagesViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        DataViewController *startingViewController = [self.modelController viewControllerAtIndex:selectedIndex storyboard:self.storyboard];
        
        NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
        [self.myPagesViewController setViewControllers:viewControllers direction:  UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
     }
    else 
     {
        NSDictionary *options = [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMid] forKey: UIPageViewControllerOptionSpineLocationKey]; 
        
        self.myPagesViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
                
        DataViewController *currentViewController = [self.modelController viewControllerAtIndex:selectedIndex storyboard:self.storyboard];
        
        NSArray *viewControllers = nil;
        
        NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
        if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) 
         {
            UIViewController *nextViewController = [self.modelController pageViewController:self.myPagesViewController viewControllerAfterViewController:currentViewController];
            viewControllers = [NSArray arrayWithObjects:currentViewController, nextViewController, nil];
        } 
        else 
         {
            UIViewController *previousViewController = [self.modelController pageViewController:self.myPagesViewController viewControllerBeforeViewController:currentViewController];
            viewControllers = [NSArray arrayWithObjects:previousViewController, currentViewController, nil];
        }
        [self.myPagesViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
     }
    
    [self.myPagesViewController setDelegate:self];
    [self.myPagesViewController setDataSource:self.modelController];

    [self addChildViewController:self.myPagesViewController];
    [self.myPageView addSubview:self.myPagesViewController.view];
    
    self.myPagesViewController.view.frame = myPageView.bounds;

    [self.myPagesViewController didMoveToParentViewController:self];

    NSArray *gestures = [NSArray arrayWithObjects:self.myPagesViewController.gestureRecognizers, self.myPageView.gestureRecognizers, nil];
    [self.myPageView.gestureRecognizers arrayByAddingObject:gestures];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self playAudio:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (ModelController *)modelController
{
    if (!myModelController) 
     {
        myModelController = [[ModelController alloc] init];
        myModelController.myPagesData = myPhotosArray;
        myModelController.myAudioData = myClipsArray;
    }
    return myModelController;
}

// Beginning of Page view methods
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)currentOrientation
{
    if (UIInterfaceOrientationIsPortrait(currentOrientation)) 
     {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = [self.myPagesViewController.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [NSArray arrayWithObject:currentViewController];
        [self.myPagesViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.myPagesViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    DataViewController *currentViewController = [self.myPagesViewController.viewControllers objectAtIndex:0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) 
     {
        UIViewController *nextViewController = [self.modelController pageViewController:self.myPagesViewController viewControllerAfterViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:currentViewController, nextViewController, nil];
    } 
    else 
     {
        UIViewController *previousViewController = [self.modelController pageViewController:self.myPagesViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:previousViewController, currentViewController, nil];
     }
    [self.myPagesViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];

    return UIPageViewControllerSpineLocationMid;
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    while (completed == NO) 
     {
        //
     }
    [self playAudio:self];
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return myPagesViewController.view;
}
// End of Page view methods
// Beginning of Actions
-(IBAction) popView:(id)sender
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(IBAction)playAudio:(id)sender
{
    DataViewController *currentViewController = [self.myPagesViewController.viewControllers objectAtIndex:0];
    [currentViewController playAudio:self];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) 
     {
        while ([currentViewController isPlaying]) 
         {
            //
         }
        DataViewController *currentViewController = [self.myPagesViewController.viewControllers objectAtIndex:1];
        [currentViewController playAudio:self];
     }
}
// End of Actions
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
    [myBackButton addTarget:self action:@selector(popView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myBackButton];
}

-(void) drawPlayButton
{
    myPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myPlayButton setFrame:CGRectMake(width*.67, height*.85, width*.33, height*.15)];
    [myPlayButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myPlayButton setBackgroundImage:button forState:UIControlStateNormal];
    [myPlayButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myPlayButton setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
    [myPlayButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size40 : size80;
    [myPlayButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myPlayButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myPlayButton];
}

-(void) drawPageView
{
    int maxHeight = height - myBackButton.frame.size.height - 10;
    int maxWidth  = maxHeight * .66666667;
    
    myPageView = [[UIScrollView alloc] init];
    [myPageView setDelegate:self];
    [myPageView setFrame:CGRectMake(width/2 - maxWidth/2, maxHeight*.015, maxWidth, maxHeight)];
    [myPageView setMinimumZoomScale:1.0];
    [myPageView setMaximumZoomScale:6.0];
    [myPageView.layer setMasksToBounds:YES];
    [myPageView.layer setBorderWidth:2.0];
    [myPageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [myPageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:myPageView];
}

- (void) drawiAdBanner
{
    CGRect adFrame = self.view.frame;
    adFrame.origin.y = self.view.frame.size.height;
    myiAdsBanner = [[ADBannerView alloc] initWithFrame:adFrame];
    
    [myiAdsBanner setDelegate:self];
    [self.view addSubview:myiAdsBanner];
    
//    self.myiAdsBanner.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
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
//    CGRect playbuttonRect   = CGRectMake(width*.67, height*.85, width*.33, height*.15);
//    
//    if(iadBannerLoaded || admobBannerLoaded)
//     {
//        int maxHeight = height - myBackButton.frame.size.height - 10 - [self getAdBannerHeight];
//        int maxWidth  =  (maxHeight * .66666667);
//        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) 
//         {
//            maxWidth = (maxHeight * .66666667) * 2;
//         }
//        
//        backButtonRect.origin.y -= [self getAdBannerHeight];
//        playbuttonRect.origin.y -= [self getAdBannerHeight];
//        
//        [UIView animateWithDuration:0.5 animations:^
//         {
//            [myBackButton   setFrame:backButtonRect];
//            [myPlayButton   setFrame:playbuttonRect];
//            [myPageView setFrame:CGRectMake(width/2 - maxWidth/2, maxHeight*.015, maxWidth, maxHeight)];
//         }];
//     }
////    else
////     {
////        int maxHeight = height - myBackButton.frame.size.height - 10;
////        int maxWidth  =  (maxHeight * .66666667);
////        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) 
////         {
////            maxWidth = (maxHeight * .66666667) * 2;
////         }
////        
////        [myPageView setFrame:CGRectMake(width/2 - maxWidth/2, maxHeight*.015, maxWidth, maxHeight)];
////     }
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
    
    int maxHeight = height - myBackButton.frame.size.height - 10;
    int maxWidth;

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) 
     {
        maxWidth  = maxHeight * .66666667;
//        self.myiAdsBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
//        self.myAdmobBanner.adSize = kGADAdSizeSmartBannerPortrait;
     }
    else
     {
        maxWidth = (maxHeight * .66666667) * 2; 
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
    
    [myBackButton       setFrame:CGRectMake(0, height*.85, width*.33, height*.15)];
    [myPlayButton       setFrame:CGRectMake(width*.67, height*.85, width*.33, height*.15)];
    [myPageView         setFrame:CGRectMake(width/2 - maxWidth/2, maxHeight*.015, maxWidth, maxHeight)];
//    [self adjustBannerView];
}
// End of Orientation methods
@end
