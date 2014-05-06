//
//  ClientManager.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import <AWSRuntime/AWSRuntime.h>

#import "ClientManager.h"
#import "KeyChainWrapper.h"
#import "S3RequestResponder.h"

@interface ClientManager ()

@property (strong, nonatomic)NSMutableArray *S3RequestResponders;

@end


static AmazonS3Client *s3  = nil;
static TVMClient *tvm = nil;

@implementation ClientManager

+(ClientManager *)sharedClientManager
{
    static ClientManager *sharedClientManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClientManager = [[self alloc] init];
        sharedClientManager.S3RequestResponders = [[NSMutableArray alloc] init];
    });
    return sharedClientManager;
}

#pragma mark -
#pragma mark S3 Request Methods
//- (NSMutableArray *)S3RequestResponders
//{
//    if (self.S3RequestResponders == nil)
//    {
//        self.S3RequestResponders = [[NSMutableArray alloc] init];
//        return self.S3RequestResponders;
//    } else {
//        return self.S3RequestResponders;
//    }
//}

+ (void)AddS3RequestResponder:(S3RequestResponder *)responder
{
    [[[ClientManager sharedClientManager] S3RequestResponders] addObject:responder];
}

+ (void)CancelAllS3Requests
{
    [[[ClientManager sharedClientManager] S3RequestResponders]
     enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         S3RequestResponder *responder = (S3RequestResponder *)obj;
         [[responder.request urlConnection] cancel];
    }];
}

+ (void)loadPhotosForPost:(Post *)post {
    NSString *fileName = [NSString stringWithFormat:@"%@.png", post.remoteID];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSData *imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    if(imageData){
        post.image = imageData;
        MSDebug(@"found photo!!!!!!");
    } else{
        MSDebug(@"Photo of post %@ does not exist. Let's download it!", post.remoteID);
        MSDebug(@"loadPhotosForPost current thread = %@", [NSThread currentThread]);
        MSDebug(@"main thread = %@", [NSThread mainThread]);
        
        // let's validate AWS credentials before going further
        if (![ClientManager validateCredentials]){
            NSLog(@"Abort loading photos for post %@", post.remoteID);
            return;
        }
        
        //        NSArray *photoKeys = [self generatePhotoKeysForPost:post withBucketName:S3BUCKET_NAME];
        
        //        NSString *photoKey = [photoKeys firstObject];
        NSString *photoKey = [NSString stringWithFormat:@"%@/original.png", post.remoteID];
        
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:photoKey withBucket:S3BUCKET_NAME];
        [request setContentType:@"image/png"];
        
        S3RequestResponder *delegate = [S3RequestResponder S3RequestResponderForPost:post];
        
        delegate.delegate = [ClientManager sharedClientManager];
        delegate.request = request;
        request.delegate = delegate;
        [ClientManager AddS3RequestResponder:delegate];
        //TODO: Why does Amazon S3 Client getobject method have to run on main thead?
        // if it is not called on main thread, the delegate will not be notified.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ClientManager s3] getObject:request];
        });
    }
}

#pragma mark -
#pragma mark S3 Responder Delegate Methods
// this will remove the S3 delegate that completed its task
//TODO: make sure NSMutableArray removeObject is thread-safe.
- (void) removeS3RequestResponder:(id)delegatee{
    [self.S3RequestResponders removeObject:(S3RequestResponder *)delegatee];
}

- (void) restartS3Request:(id)delegatee{
    Post *post = [(S3RequestResponder *)delegatee post];
    [self.S3RequestResponders removeObject:(S3RequestResponder *)delegatee];
    [ClientManager loadPhotosForPost:post];
}

#pragma mark -
#pragma mark Setup Methods

+(void)setup:(NSString *)accessKey secretKey:(NSString *)secretKey securityToken:(NSString *)token expiration:(NSString *)expiration
{
    [KeyChainWrapper storeCredentialsInKeyChain:accessKey secretKey:secretKey securityToken:token expiration:expiration];
}

+(AmazonS3Client *)s3
{
    BOOL success = [ClientManager validateCredentials];
    if (!success)
        NSLog(@"Failed to validate credentials! S3 client is invalid.");
    return s3;
}

+(TVMClient *)tvm
{
    if (tvm == nil) {
        tvm = [[TVMClient alloc] initWithEndpoint:BASE_URL];
    }
    
    return tvm;
}

+(bool)isLoggedIn
{
    return ([KeyChainWrapper getSessionTokenForUser] != nil);
}


+(void)login:(NSString *)FBAccessToken delegate:(id<TVMClientDelegate>)delegate
{
    [ClientManager tvm].delegate = delegate;
    [[ClientManager tvm] login:FBAccessToken];
}

+(BOOL) logout
{
    return [[ClientManager tvm] logout];
}

+(BOOL)validateCredentials
{
    if ([KeyChainWrapper areAWSCredentialsExpired])
    {
        BOOL succeeded = [[ClientManager tvm] getToken];
        if (succeeded)
        {
            [ClientManager initClient];
        } else {
            return false;
        }
    }
    /*}
    
    else if (s3 == nil)
    {
        @synchronized(self)
        {
            if (s3 == nil)
            {
                [ClientManager initClient];
            }
        }
    }
    */
    return true;
     
}

+(void)initClient
{
    AmazonCredentials *credentials = [KeyChainWrapper getAWSCredentialsFromKeyChain];
    
    s3  = [[AmazonS3Client alloc] initWithCredentials:credentials];
    //s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
}

+(void)sendDeviceToken
{
    NSData *deviceToken = [KeyChainWrapper deviceToken];
    MSDebug(@"device token: %@", deviceToken);
    
    // we wait for both device token and session token are ready
    if (deviceToken == NULL) {
        return;
    } else if (![KeyChainWrapper isSessionTokenValid]) {
        return;
    }
    MSDebug(@"Ready to send device token: %@", deviceToken);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[deviceToken, [KeyChainWrapper getSessionTokenForUser]]
                                                                     forKeys:@[@"device_token", @"auth_token"]];

    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"set_device_token"
                                                                                          object:self
                                                                                      parameters:params];
    
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        MSDebug(@"Device Token posted");
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [Utility generateAlertWithMessage:@"Network problem" error:nil];
                                         });
                                         MSError(@"Cannot set device token!");
                                     }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
}

+ (void)sendBadgeNumber:(NSInteger)number
{
    if (![KeyChainWrapper isSessionTokenValid]) {
        MSError(@"User session token is not valid.");
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    MSDebug(@"badge number: %i", number);
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[sessionToken, [NSNumber numberWithInteger:number]]
                                                                     forKeys:@[@"auth_token", @"badge_number"]];
    
    
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"set_badge"
                                                                                          object:self
                                                                                      parameters:params];
    
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = number;
        });
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [Utility generateAlertWithMessage:@"Network problem" error:nil];
                                         });
                                         MSError(@"Cannot set badge number!");
                                     }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
}

@end
