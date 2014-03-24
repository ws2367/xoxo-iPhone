//
//  Entity.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Institution, Post;

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSString * institutionUUID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * isYourFriend;
@property (nonatomic, retain) NSNumber * fbUserID;
@property (nonatomic, retain) Institution *institution;
@property (nonatomic, retain) NSSet *posts;
@end

@interface Entity (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
