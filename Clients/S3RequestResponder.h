//
//  S3RequestResponder.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/25/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import "Post.h"

@protocol S3RequestResponderDelegate;

@interface S3RequestResponder: NSObject <AmazonServiceRequestDelegate>

@property (nonatomic, weak) id<S3RequestResponderDelegate> delegate;

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) S3Request *request;

+ (S3RequestResponder *) S3RequestResponderForPost:(Post *)post;

@end



@protocol S3RequestResponderDelegate <NSObject>

@required

- (void) removeS3RequestResponder:(id)delegatee;
- (void) restartS3Request:(id)delegatee;

@end
