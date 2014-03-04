//
//  Photo.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * dirty;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Post *post;

@end
