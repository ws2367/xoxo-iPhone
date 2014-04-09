//
//  Entity.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/9/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSString * fbUserID;
@property (nonatomic, retain) NSString * institution;
@property (nonatomic, retain) NSNumber * isYourFriend;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *posts;
@end

@interface Entity (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
