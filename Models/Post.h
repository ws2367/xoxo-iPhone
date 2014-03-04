//
//  Post.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Entity, Photo, User;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) id entitiesIDs;
@property (nonatomic, retain) NSNumber * isYours;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *entities;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) User *user;
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

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
