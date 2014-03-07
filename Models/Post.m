//
//  Post.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/7/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Post.h"
#import "Comment.h"
#import "Entity.h"
#import "Photo.h"
#import "User.h"


@implementation Post

@dynamic content;
@dynamic deleted;
@dynamic dirty;
@dynamic entitiesUUIDs;
@dynamic isYours;
@dynamic remoteID;
@dynamic updateDate;
@dynamic uuid;
@dynamic comments;
@dynamic entities;
@dynamic photos;
@dynamic user;

@end
