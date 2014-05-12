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
#import "NSNumber+MSNumber.h"

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

- (void)sendReportRequestWithFailureBlock:(void (^)(void))failureBlock
{
    if (![KeyChainWrapper isSessionTokenValid]) {
        [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
        return;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"report_post"
                                                                     object:self
                                                                 parameters:@{@"auth_token": sessionToken}];
    
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (failureBlock) {failureBlock();}
                                     }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];

}


- (void)reportShareToServerWithFailureBlock:(void (^)(void))failureBlock{
    if (![KeyChainWrapper isSessionTokenValid]) {
        [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
        return;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"share_post"
                                                                                          object:self
                                                                                      parameters:@{@"auth_token": sessionToken}];
    
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (failureBlock) {failureBlock();}
                                     }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
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
    [self setCommentsCount:[[self commentsCount] increment]];
}

+ (void)setIndicesAsRefreshing:(NSArray *)posts
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, nil]];
    [request setFetchLimit:1];
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    NSNumber *smallestIndex = nil;
    if ([match count] > 1) {
        MSError(@"Fetched more than the fetch limit!");
        return;
    } else if ([match count] == 0){
        // Yet downloaded any posts
        smallestIndex = [NSNumber numberWithInt:0];
    } else {
       smallestIndex = [[match firstObject] index];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"popularity" ascending:YES];
    NSArray *sortedPosts = [posts sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    for (Post *post in sortedPosts) {
        if ([post.index isEqual:@0]) {
            if ([(smallestIndex = [smallestIndex decrement]) isEqual:@0] )
            {
                smallestIndex = [smallestIndex decrement];
            }
            
            [post setIndex:smallestIndex];
        }
    }
}

+ (void)setIndicesAsLoadingMore:(NSArray *)posts
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sortByIndex = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortByIndex, nil]];
    [request setFetchLimit:1];
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    if ([match count] > 1) {
        MSError(@"Fetched more than the fetch limit!");
    } else if ([match count] == 0){
        // an empty array
        // do nothing
        // Loading more should not happen when there were no posts before
    } else {
        NSNumber *biggestIndex = [[match firstObject] index];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"popularity" ascending:NO];
        NSArray *sortedPosts = [posts sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        for (Post *post in sortedPosts) {
            if ([post.index isEqual:@0]) {
                if ([(biggestIndex = [biggestIndex increment]) isEqual:@0])
                {
                    biggestIndex = [biggestIndex increment];
                }
                [post setIndex:biggestIndex];
            }
        }
    }
}

@end
