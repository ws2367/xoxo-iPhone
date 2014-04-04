//
//  Post+MSS3Client.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Post+MSS3Client.h"
#import "ClientManager.h"

@implementation Post (MSS3Client)

- (BOOL) uploadImageToS3{
    if (![ClientManager validateCredentials]){
        NSLog(@"Abort uploading photos to S3");
        return NO;
    }
    
    NSString *photoKey = [NSString stringWithFormat:@"%@/original.png", self.remoteID];
        
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:photoKey inBucket:S3BUCKET_NAME];
    por.contentType = @"image/png";
    por.data = self.image;
    S3PutObjectResponse *response = [[ClientManager s3] putObject:por];
    if (response.error != nil) {
        NSLog(@"Error while uploading photos");
    } else {
        MSDebug(@"Photo of posts %@ loaded!", self.remoteID);
    }

    // then we can save all the stuff to database
//    [Utility saveToPersistenceStore:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
//                     failureMessage:@"Failed to save the managed object context."];
    
    return YES;
}

@end
