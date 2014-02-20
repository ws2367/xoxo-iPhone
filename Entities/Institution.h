//
//  Institution.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/19/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entity, Location;

@interface Institution : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) Entity *entities;

@end
