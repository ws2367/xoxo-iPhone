//
//  Post.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 5/7/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Entity;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * following;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * isYours;
@property (nonatomic, retain) NSNumber * popularity;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *entities;
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

@end
