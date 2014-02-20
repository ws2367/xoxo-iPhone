//
//  Entity.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/19/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Institution, Post;

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSSet *posts;
@property (nonatomic, retain) Institution *institution;
@end

@interface Entity (CoreDataGeneratedAccessors)

- (void)addPostsObject:(Post *)value;
- (void)removePostsObject:(Post *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
