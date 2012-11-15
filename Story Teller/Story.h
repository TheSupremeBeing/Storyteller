//
//  Story.h
//  Story Teller
//
//  Created by Logan on 11/9/12.
//  Copyright (c) 2012 ME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Story : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id cover;
@property (nonatomic) NSTimeInterval date;

@end
