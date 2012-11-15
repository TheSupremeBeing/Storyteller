//
//  MasterViewController.m
//  Story Teller
//
//  Created by Logan Isitt on 4/8/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import "MasterViewController.h"
//#import "GADBannerView.h"

@implementation MasterViewController
@synthesize fetchedResultsController, managedObjectContext, debug;
@synthesize myTitle, myTable, myiAdsBanner;

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    width   = self.view.frame.size.width;
    height  = self.view.frame.size.height;
        
    [self drawTable];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self setupFetchedResultsController:@"Story" andKey:@"name"];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
    [myTable reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
// Beginning of Table methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    //Rects
    CGRect iPadCoverRectPotrait     = CGRectMake(51,  36, 204, 136);
    CGRect iPadCoverRectLandscape   = CGRectMake(65,  36, 204, 136);
    CGRect iPhoneCoverRectPotrait   = CGRectMake(27,  16, 90,  60);
    CGRect iPhoneCoverRectLandscape = CGRectMake(27,  16, 90,  60);
    
    CGRect iPadNameRectPotrait      = CGRectMake(280, 50, 396, 58);
    CGRect iPhoneNameRectPotrait    = CGRectMake(125, 20, 165, 24);
    CGRect iPadInfoRectPotrait      = CGRectMake(280, 116, 396, 58);
    CGRect iPhoneInfoRectPotrait    = CGRectMake(125, 45, 165, 24);    
    
    UIImage *image = [UIImage imageNamed:@"Cell.png"];
    UIImageView *background = [[UIImageView alloc] initWithImage:image];
    [cell setBackgroundView:background];
    
    if (indexPath.section == myTable.numberOfSections - 1 || myTable.numberOfSections == 1)
     {
        CGRect labelRect = CGRectMake(width*.06, cell.frame.size.height/2, width*.88, cell.frame.size.height);
        CGRect iPadLabelRectPotrait = CGRectMake(width*.06, 52, width*.88, 105);
        UILabel *label = [[UILabel alloc] init];
        [label setFrame:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? labelRect : iPadLabelRectPotrait];
        [label setText:NSLocalizedString(@"Create Story", nil)];
        [label setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 35 : 75]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:UITextAlignmentCenter];
        [label setAdjustsFontSizeToFitWidth:YES];
        [cell addSubview:label];
     }
    else
     {
        myStory = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        UIImage *coverImage =   myStory.cover;
        UIImageView *albumCover = [[UIImageView alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) 
         {
            [albumCover setFrame:UIDeviceOrientationIsPortrait(self.interfaceOrientation) ? iPhoneCoverRectPotrait : iPhoneCoverRectLandscape];
         }
        else 
         {
            [albumCover setFrame:UIDeviceOrientationIsPortrait(self.interfaceOrientation) ? iPadCoverRectPotrait : iPadCoverRectLandscape];
         }
        [albumCover setContentMode:UIViewContentModeScaleAspectFill];
        [albumCover setBackgroundColor:[UIColor clearColor]];
        [albumCover setImage:coverImage];
        [cell addSubview:albumCover];
        
        UILabel *albumTitle = [[UILabel alloc] init];
        [albumTitle setFrame:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? iPhoneNameRectPotrait : iPadNameRectPotrait];
        [albumTitle setText:myStory.name]; 
        [albumTitle setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 20 : 43]];
        [albumTitle setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:albumTitle];
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:myStory.date];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateStyle:NSDateFormatterShortStyle];
        [format setTimeStyle:NSDateFormatterNoStyle];
        
        UILabel *albumUpdated = [[UILabel alloc] init];
        [albumUpdated setFrame:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? iPhoneInfoRectPotrait : iPadInfoRectPotrait];
        [albumUpdated setText:[NSString stringWithFormat:NSLocalizedString(@"Created:", nil), [format stringFromDate:date]]];
        [albumUpdated setFont:[UIFont fontWithName:@"Bradley Hand" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 20 : 43]];
        [albumUpdated setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:albumUpdated];
     }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == myTable.numberOfSections - 1 ? NO : YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == myTable.numberOfSections - 1)
     {
        [self performSegueWithIdentifier:@"AlbumView" sender:self];
     }
    else
     {
        [self performSegueWithIdentifier:@"DetailView" sender:nil];
     }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
       Story *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
       NSString *name = story.name;
       [self.managedObjectContext deleteObject:story];
       [self.managedObjectContext save:nil];
       [self setupFetchedResultsController:@"Story" andKey:@"name"];
       
       [self setupFetchedResultsController:@"Pages" andKey:@"story"];
       for (int i = 0; i < [self.fetchedResultsController.fetchedObjects count]; i++) 
        {
           Pages *page = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
           if ([page.story isEqualToString:name]) 
            {
               [[NSFileManager defaultManager] removeItemAtPath:page.clips error:nil];
               [[NSFileManager defaultManager] removeItemAtPath:page.paths error:nil];
               [[NSFileManager defaultManager] removeItemAtPath:page.thumb error:nil];
               [self.managedObjectContext deleteObject:page];
            }
        }
       [self.managedObjectContext save:nil];
       [self setupFetchedResultsController:@"Story" andKey:@"name"];
       [tableView reloadData];
    } 
}
// End of Table methods
// Beginning of Transtion methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"DetailView"])
     {
        myStory = [self.fetchedResultsController objectAtIndexPath:[myTable indexPathForSelectedRow]];
        [self setupFetchedResultsController:@"Pages" andKey:@"story"];
		DetailViewController *detailView = segue.destinationViewController;
        selectedPath = [myTable indexPathForSelectedRow].row;
        detailView.storyName = myStory.name;
        detailView.managedObjectContext = self.managedObjectContext;
     }
    if ([segue.identifier isEqualToString:@"AlbumView"]) 
     {
        AddAlbumViewController *albumView = segue.destinationViewController;
        albumView.managedObjectContext = self.managedObjectContext;
     }
}
// End of Transition methods
// Beginning of Core Data methods
- (void)setupFetchedResultsController:(NSString *) entityName andKey:(NSString *) key
{    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:key
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
// Core Data Ends
// Begin of Layout
-(void) drawTitle
{
    myTitle = [[UIImageView alloc] init];
    [myTitle setFrame:UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? titleRectPortrait : titleRectLandscape];
    [myTitle setContentMode:UIViewContentModeScaleAspectFill];
    [myTitle setBackgroundColor:[UIColor clearColor]];
    
    UIImage *image = [UIImage imageNamed:NSLocalizedString(@"woodText.png", nil)];
    [myTitle setImage:image];
    [self.view addSubview:myTitle];
}
-(void) drawTable
{
    myTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [myTable setFrame:CGRectMake(0, height*.25, width, height*.75)];
    [myTable setDelegate:self];
    [myTable setDataSource:self];
    [myTable setBackgroundColor:[UIColor clearColor]];
    [myTable setRowHeight:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 96 : 210];
    [myTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:myTable];
}
// Beginning of Orientation methods
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    width   = self.view.frame.size.width;
    height  = self.view.frame.size.height;
  
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
     {
        titleRectPortrait = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?  
                CGRectMake(0, height*.02, width, height *.20) : CGRectMake(0, height*.02, width, height *.20);
     }
    else 
     {
        titleRectLandscape = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?  
                CGRectMake(width/4, height*.06, width/2, height *.10) : CGRectMake(width/6, height*.04, 4*width/6, height *.15);

     }
    
    [myTable setFrame:CGRectMake(0, height*.25, width, height*.75)];
    [myTable reloadData];
    [myTitle removeFromSuperview];
    [self drawTitle];
}
// End of Orientation methods
@end