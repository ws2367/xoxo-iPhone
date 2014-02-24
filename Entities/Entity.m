//
//  Entity.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/19/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Entity.h"
#import "Institution.h"
#import "Post.h"


@implementation Entity

// @dynamic is basically suppressing the compiler warning
// in the runtime, Core Data will take care of the implementation
// of @synchronize, setters and getters by responding to a
// trapping mechanism
@dynamic name;
@dynamic remoteId;
@dynamic posts;
@dynamic institution;

@end
