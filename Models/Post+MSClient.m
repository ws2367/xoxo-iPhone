//
//  Post+MSClient.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Post+MSClient.h"
#import "ClientManager.h"
#import "KeyChainWrapper.h"

@implementation Post (MSClient)

- (bool) uploadImageToS3{
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
        MSError(@"Error while uploading photos");
    } else {
        MSDebug(@"Photo of posts %@ loaded!", self.remoteID);
        if (![KeyChainWrapper isSessionTokenValid]) {
            [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
            return false;
        }
        NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
        
        NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"activate_post"
                                                                                              object:self
                                                                                          parameters:@{@"auth_token": sessionToken}];
        
        RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:nil
                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [Utility generateAlertWithMessage:@"Network problem" error:error];
                                             MSError(@"Cannot activate post!");
                                         }];
        
        NSOperationQueue *operationQueue = [NSOperationQueue new];
        [operationQueue addOperation:operation];

    }

    // then we can save all the stuff to database
//    [Utility saveToPersistenceStore:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
//                     failureMessage:@"Failed to save the managed object context."];
    
    return YES;
}

- (void)sendFollowRequestWithFailureBlock:(void (^)(void))failureBlock
{
    bool toFollow = ![[self following] boolValue];
    
    if (![KeyChainWrapper isSessionTokenValid]) {
        [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
        return;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSMutableURLRequest *request = nil;
    if (toFollow) {
        request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"follow_post"
                                                                         object:self
                                                                     parameters:@{@"auth_token": sessionToken}];
        
        
    } else {
        request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"unfollow_post"
                                                                         object:self
                                                                     parameters:@{@"auth_token": sessionToken}];
    }
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self setFollowing:[NSNumber numberWithBool:(toFollow ? YES: NO)]];
        [self setFollowersCount:[NSNumber numberWithInt:([[self followersCount] intValue] + (toFollow ? 1: -1))]];
        //TODO: not sure if we need to run saveToPersistentStore here
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failureBlock) {failureBlock();}
    }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
    
}

- (void)incrementCommentsCount
{
    [self setCommentsCount:[NSNumber numberWithInt:([[self commentsCount] intValue] + 1)]];
}

@end
