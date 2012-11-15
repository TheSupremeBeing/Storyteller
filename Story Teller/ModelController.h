//
//  ModelController.h
//  Pages
//
//  Created by Logan Isitt on 5/22/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray *myPagesData;
@property (strong, nonatomic) NSArray *myAudioData;
- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end
