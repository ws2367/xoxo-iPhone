//
//  Comment.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/19/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Comment : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * hatersNum;
@property (nonatomic, retain) NSNumber * likersNum;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) Post *post;

@end
