//
//  Institution.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entity, Location;

@interface Institution : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * locationID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet *entities;
@property (nonatomic, retain) Location *location;
@end

@interface Institution (CoreDataGeneratedAccessors)

- (void)addEntitiesObject:(Entity *)value;
- (void)removeEntitiesObject:(Entity *)value;
- (void)addEntities:(NSSet *)values;
- (void)removeEntities:(NSSet *)values;

@end
