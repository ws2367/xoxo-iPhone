//
//  S3RequestResponder.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/25/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "S3RequestResponder.h"

@interface S3RequestResponder ()

@property (strong, nonatomic) Post *post;
    
@end

@implementation S3RequestResponder

+ (S3RequestResponder *) S3RequestResponderForPost:(Post *)post{
    return [[S3RequestResponder alloc] initWithPost:post];
}

- (id)initWithPost:(Post *)post{
    self = [super init];
    if (self) {
        _post = post;
    }
    return self;
}

// we are sure that the photo of the same uuid does not exist in core data
- (void) saveImageData:(NSData *)imageData
                toPost:(Post *)post
inManagedObjectContext:(NSManagedObjectContext *)context{
    
    // This will save NSData typed image to an external binary storage
    post.image = imageData;
}

#pragma mark -
#pragma mark Amazon Service Request Delegate Methods

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    if (response.error) {
        [Utility generateAlertWithMessage:@"failed to upload photos." error:nil];
    }
    
    [self saveImageData:response.body
                 toPost:_post
 inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    
    //let's save all the photos we just created!
    NSError *error;
    if ([[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:&error]) {
        MSDebug(@"Successfully saved the photos!");
    } else {
        MSError(@"Failed to save the managed object context.");
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(removeS3RequestResponder:)]) {
        [self.delegate removeS3RequestResponder:self];
    } else {
        MSError(@"S3 delegate's delegation is not set!");
    }
    
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
        //do nothing for now
}


- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    [Utility generateAlertWithMessage:@"failed to upload photos." error:nil];
}

@end
