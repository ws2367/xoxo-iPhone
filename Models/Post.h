//
//  Post.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "InitializedNSManagedObject.h"

@class Comment, Entity, User;

@interface Post : InitializedNSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *entities;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addEntitiesObject:(Entity *)value;
- (void)removeEntitiesObject:(Entity *)value;
- (void)addEntities:(NSSet *)values;
- (void)removeEntities:(NSSet *)values;

- (void)addPhotosObject:(NSManagedObject *)value;
- (void)removePhotosObject:(NSManagedObject *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
