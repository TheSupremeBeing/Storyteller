//
//  DetailViewController.m
//  Story Teller
//
//  Created by Logan Isitt on 4/8/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageExtras.h"
//#import "GADBannerView.h"

#define size40  [NSLocalizedString(@"40", nil) intValue]  
#define size80  [NSLocalizedString(@"80", nil) intValue]

@implementation DetailViewController
@synthesize storyName;
@synthesize fetchedResultsController, managedObjectContext, debug;
@synthesize myTitle, myImageGallery, myBackButton, myEditButton, myAddButton, myiAdsBanner;

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myTitle.text = storyName;
    
    width = self.view.frame.size.width;
    height = self.view.frame.size.height;
    
    myClips = [[NSMutableArray alloc] init];
    myThumbs = [[NSMutableArray alloc] init];
    myImages = [[NSMutableArray alloc] init];
    
    isEditing = NO;
        
    [self drawTitle];
    [self drawBackButton];
    [self drawEditButton];
    [self drawAddButton];
    
    myImageGallery = [[UIScrollView alloc] init];
    [self.view addSubview:myImageGallery];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

-(void)viewDidDisappear:(BOOL)animated
{    
    [super viewDidDisappear:YES];
}

- (void) prepareView
{
    [self setupFetchedResultsController:@"Pages"];

    for (int i = 100; i < [myThumbs count] + 100; i ++)
     {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        [btn removeFromSuperview];
     }

    [myImages removeAllObjects];
    [myThumbs removeAllObjects];
    [myClips removeAllObjects];
    for (int i = 0; i < [self.fetchedResultsController.fetchedObjects count]; i++)
     {
        Pages *myPage = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
        [myThumbs   addObject:myPage.thumb];
        NSLog(@"%@", myPage.thumb);
        [myClips    addObject:[NSURL fileURLWithPath:myPage.clips]];
        [myImages   addObject:myPage.paths];
     }

    int picsPerRow  = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 3 : 4;
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) 
     {
        picsPerRow  = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 5 : 6;
     }
    int imageWidth  = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 60 : 120;
    int imageHeight = imageWidth * 1.5;
    
   	int row = 0;
	int column = 0;
	for(int i = 0; i < [myThumbs count]; ++i)
     {               
         UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
         button.frame = CGRectMake(column*(imageWidth+20) + 10, row*(imageHeight+20) + 10, imageWidth, imageHeight);
         [button setContentMode:UIViewContentModeScaleToFill];
         [button setImage:[UIImage imageWithContentsOfFile:[myThumbs objectAtIndex:i]] forState:UIControlStateNormal];
         [button addTarget:self action:@selector(pushToPhotoView:) forControlEvents:UIControlEventTouchUpInside];
         button.tag = i + 100; 
         
         CALayer * btnLayer = [button layer];
         [btnLayer setMasksToBounds:YES];
         [btnLayer setCornerRadius:0];
         [btnLayer setBorderWidth:2];
         [btnLayer setBorderColor:[[UIColor whiteColor] CGColor]];
         
         [myImageGallery addSubview:button];
         
         if (column == picsPerRow) 
          {
             column = 0;
             row++;
          } 
         else {
             column++;
         }
         
     }

    [myImageGallery setContentSize:CGSizeMake(320, (row+1) * 110)];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
     {
       	[myImageGallery setContentSize:CGSizeMake(700, (row+1) * 200)];
     }
}

// Beginning of Transitions
-(IBAction) popBackView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) pushToPhotoView:(UIButton *) btn
{
    [self performSegueWithIdentifier:@"ToPhotoView" sender:btn];
}

-(IBAction)addPressed:(id)sender
{
    [self performSegueWithIdentifier:@"AddPhoto" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *) btn
{
	if ([segue.identifier isEqualToString:@"AddPhoto"])
     {
        [self setupFetchedResultsController:@"Pages"];
		AddPhotosViewController *addPhotoView = segue.destinationViewController;
        addPhotoView.managedObjectContext = self.managedObjectContext;
        addPhotoView.storyName = self.storyName;
        addPhotoView.pages = [self.fetchedResultsController.fetchedObjects count];
     }
    if ([segue.identifier isEqualToString:@"ToPhotoView"])
     {
		PhotoViewController *photoView = segue.destinationViewController;
        photoView.selectedIndex     = btn.tag - 100;
        photoView.myPhotosArray     = [[NSMutableArray alloc] initWithArray:myImages];
        photoView.myClipsArray      = [[NSMutableArray alloc] initWithArray:myClips];
     }
}
// End of Transitions
// Beginning of Core Data
- (void)setupFetchedResultsController:(NSString *) entityName
{    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName]; 
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"story"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];    
    request.predicate = [NSPredicate predicateWithFormat:@"story like %@", storyName]; 
   
    
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
// Beginning of Thumb Methods
-(IBAction) editImages:(id)sender
{
    if (isEditing) 
     {
        for (int i = 0; i < [myThumbs count]; i++) 
         {
            UIButton *toEnable = (UIButton *) [self.view viewWithTag:i + 100];
            [toEnable setEnabled:YES];
            
            UIButton *button = (UIButton *)[self.view viewWithTag:i + 100 + [myThumbs count]];
            [button removeFromSuperview];
         }
        isEditing = NO;
        [myEditButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
     }
    else 
     {
        isEditing = YES;
        int picsPerRow  = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 3 : 4;
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) 
         {
            picsPerRow  = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 5 : 6;
         }
        int imageWidth  = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 60 : 120;
        int imageHeight = imageWidth * 1.5;
        int buttonWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 30 : 40;

        int row = 0;
        int column = 0;
        for(int i = 0; i < [myImages count]; ++i) 
         {       
             UIButton *toDisable = (UIButton *) [self.view viewWithTag:i + 100];
             toDisable.adjustsImageWhenDisabled = NO;
             [toDisable setEnabled:NO];
             
             UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
             button.frame = CGRectMake(column*(imageWidth+20), row*(imageHeight+20), buttonWidth, buttonWidth);
             [button setImage:[UIImage imageNamed:@"DeleteBtn.png"] forState:UIControlStateNormal];
             [button addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
             button.tag = [myImages count] + i + 100; 
             
             [myImageGallery addSubview:button];
             
             if (column == picsPerRow) 
              {
                 column = 0;
                 row++;
              } 
             else {
                 column++;
             }
             
         }
        [myEditButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
     }
}

-(void) deleteImage: (UIButton *) btn
{
    int photoIndex = btn.tag - [myThumbs count];
    UIButton *deleteBtn = (UIButton *)[self.view viewWithTag:btn.tag];
    UIButton *other = (UIButton *)[self.view viewWithTag:photoIndex];
    [deleteBtn removeFromSuperview];
    [other removeFromSuperview];
    Pages *page = [self.fetchedResultsController.fetchedObjects objectAtIndex:photoIndex - 100];
    
    [[NSFileManager defaultManager] removeItemAtPath:page.thumb error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:page.paths error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:page.clips error:nil];
    [self.managedObjectContext deleteObject:page];
    [self.managedObjectContext save:nil];
    
    [self editImages:self];
    [self prepareView];
    [self editImages:self];
}
// End of Thumb Methods
// Beginning of Layout Methods
-(void) drawTitle
{
    myTitle = [[UILabel alloc] init];
    [myTitle setFrame:CGRectMake(0, 0, width, height*.20)];
    [myTitle setBackgroundColor:[UIColor clearColor]];
    [myTitle setText:storyName];
    [myTitle setTextAlignment:UITextAlignmentCenter];
    [myTitle setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 50 : 100]];
    [myTitle setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:myTitle];
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

-(void) drawEditButton
{
    myEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myEditButton setFrame:CGRectMake(width*.335, height*.85, width*.33, height*.15)];
    [myEditButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myEditButton setBackgroundImage:button forState:UIControlStateNormal];
    [myEditButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myEditButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [myEditButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size40 : size80;
    [myEditButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myEditButton addTarget:self action:@selector(editImages:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myEditButton];
}

-(void) drawAddButton
{
    myAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myAddButton setFrame:CGRectMake(width*.67, height*.85, width*.33, height*.15)];
    [myAddButton setContentMode:UIViewContentModeScaleAspectFill];
    UIImage *button = [UIImage imageNamed:@"SmallBtn.png"];
    UIImage *clicked = [UIImage imageNamed:@"clickedBtn"];
    [myAddButton setBackgroundImage:button forState:UIControlStateNormal];
    [myAddButton setBackgroundImage:clicked forState:UIControlStateHighlighted];
    [myAddButton setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
    [myAddButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    int fontSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? size40 : size80;
    [myAddButton.titleLabel setFont:[UIFont fontWithName:@"Bradley Hand" size:fontSize]];
    [myAddButton addTarget:self action:@selector(addPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myAddButton];
}
// End of Layout
// Beginning of Orientation methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    width   = self.view.frame.size.width;
    height  = self.view.frame.size.height;
    if (isEditing == YES)
     {
        [self editImages:self];
     }

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
     {
        galleryRect = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 
        CGRectMake(0, height*.15, width, height*.7) : CGRectMake(width*.044, height*.15, width*.911, height*.7);
     }
    else 
     {
        galleryRect = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 
        CGRectMake(0, height*.18, width, height*.67) : CGRectMake(width*.02, height*.16, width*.96, height*.7);
     }

    [myTitle        setFrame:CGRectMake(0, 0, width, height*.20)];
    [myBackButton   setFrame:CGRectMake(0, height*.85, width*.33, height*.15)];
    [myEditButton   setFrame:CGRectMake(width*.335, height*.85, width*.33, height*.15)];
    [myAddButton    setFrame:CGRectMake(width*.67, height*.85, width*.33, height*.15)];
    [myImageGallery setFrame:galleryRect];

    [self prepareView];
}
// End of Orientation methods
@end
