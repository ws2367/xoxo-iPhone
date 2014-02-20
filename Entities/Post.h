//
//  Post.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/19/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entity;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *entities;
@property (nonatomic, retain) NSManagedObject *user;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addEntitiesObject:(Entity *)value;
- (void)removeEntitiesObject:(Entity *)value;
- (void)addEntities:(NSSet *)values;
- (void)removeEntities:(NSSet *)values;

@end
