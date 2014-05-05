//
//  S3RequestResponder.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/25/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "S3RequestResponder.h"

@interface S3RequestResponder ()
    
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
    // this has to be done on main thread so fetched result controller will know the update

    post.image = imageData;
    NSString *fileName = [NSString stringWithFormat:@"%@.png", post.remoteID];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    BOOL succeed = [imageData writeToFile:filePath atomically:YES];
    if(succeed){
        MSDebug(@"succesfully saved");
    }else{
        MSDebug(@"failed to saved");
    }
}

#pragma mark -
#pragma mark Amazon Service Request Delegate Methods

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (response.error) {
            //[Utility generateAlertWithMessage:@"failed to upload photos." error:nil];
            if (self.delegate && [self.delegate respondsToSelector:@selector(restartS3Request:)]) {
                [self.delegate restartS3Request:self];
            } else {
                MSError(@"S3 delegate's delegation is not set!");
            }
        }
        
        MSDebug(@"AmazonServiceRequestDelegate current thread = %@", [NSThread currentThread]);
        MSDebug(@"main thread = %@", [NSThread mainThread]);
        
        //TODO: not sure if this has to be run on main thread... its about fetchedresultcontroller change notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveImageData:response.body
                         toPost:_post
         inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
        });
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
    });
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
        //do nothing for now

}


- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(restartS3Request:)]) {
        [self.delegate restartS3Request:self];
    } else {
        MSError(@"S3 delegate's delegation is not set!");
    }
    MSDebug(@"Failed with AWS request");
}

@end
