//
//  Photo.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "InitializedNSManagedObject.h"

@class Post;

@interface Photo : InitializedNSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) Post *post;

@end
