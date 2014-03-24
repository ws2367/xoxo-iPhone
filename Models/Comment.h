//
//  Comment.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * anonymizedUserID;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) NSNumber * isYours;
@property (nonatomic, retain) NSString * postUUID;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Post *post;

@end
