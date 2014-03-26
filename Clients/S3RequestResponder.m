//
//  S3RequestResponder.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/25/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "S3RequestResponder.h"
#import "Photo.h"

@interface S3RequestResponder ()

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) NSString *uuid;
    
@end

@implementation S3RequestResponder

+ (S3RequestResponder *) S3RequestResponderForPost:(Post *)post uuid:(NSString *)uuid{
    return [[S3RequestResponder alloc] initWithPost:post uuid:uuid];
}

- (id)initWithPost:(Post *)post uuid:(NSString *)uuid{
    self = [super init];
    if (self) {
        _post = post;
        _uuid = uuid;
    }
    return self;
}

// we are sure that the photo of the same uuid does not exist in core data
- (void) createPhotoEntityForPost:(Post *)post
                     andImageData:(NSData *)imageData
                          andUUID:(NSString *)uuid
           inManagedObjectContext:(NSManagedObjectContext *)context{
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                 inManagedObjectContext:context];
    
    // This will save NSData typed image to an external binary storage
    photo.image = imageData;
    [photo setDirty:@NO];// dirty is a NSNumber so @NO is a literal in Obj C that is created for this purpose. [NSNumber numberWithBool:] works too.
    [photo setDeleted:@NO];
    [photo setUuid:uuid];
    
    [post addPhotosObject:photo];
}

#pragma mark -
#pragma mark Amazon Service Request Delegate Methods

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    if (response.error) {
        [Utility generateAlertWithMessage:@"failed to upload photos." error:nil];
    }
    
    [self createPhotoEntityForPost:_post
                      andImageData:response.body
                           andUUID:_uuid
            inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    
    //let's save all the photos we just created!
    NSError *error;
    if ([[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext saveToPersistentStore:&error]) {
        MSDebug(@"Successfully saved the photos!");
    } else {
        NSLog(@"Failed to save the managed object context.");
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(removeS3RequestResponder:)]) {
        [self.delegate removeS3RequestResponder:self];
    } else {
        NSLog(@"S3 delegate's delegation is not set!");
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
