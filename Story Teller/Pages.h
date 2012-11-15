//
//  Pages.h
//  Story Teller
//
//  Created by Logan on 11/9/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pages : NSManagedObject

@property (nonatomic, retain) NSString * thumb;
@property (nonatomic, retain) NSString * clips;
@property (nonatomic, retain) NSString * paths;
@property (nonatomic, retain) NSString * story;

@end
