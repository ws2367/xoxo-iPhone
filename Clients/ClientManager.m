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


#import "ClientManager.h"
#import "KeyChainWrapper.h"
//#import "Response.h"

#import <AWSRuntime/AWSRuntime.h>

//#import "KeyChainWrapper.h"

static AmazonS3Client *s3  = nil;
static TVMClient *tvm = nil;

@implementation ClientManager

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
        tvm = [[TVMClient alloc] initWithEndpoint:TOKEN_VENDING_MACHINE_URL];
    }
    
    return tvm;
}

+(bool)isLoggedIn
{
    return ([KeyChainWrapper getSessionTokenForUser] != nil);
}

+(BOOL)login:(NSString *)FBAccessToken
{
    return [[ClientManager tvm] login:FBAccessToken];
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
    NSLog(@"init client");
    AmazonCredentials *credentials = [KeyChainWrapper getAWSCredentialsFromKeyChain];
    
    s3  = [[AmazonS3Client alloc] initWithCredentials:credentials];
    //s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
}

/*
+(void)wipeAllCredentials
{
    @synchronized(self)
    {
        [KeyChainWrapper wipeCredentialsFromKeyChain];
        
        [s3 release];
        [sdb release];
        [sns release];
        [sqs release];
        
        s3  = nil;
        sdb = nil;
        sqs = nil;
        sns = nil;
    }
}
*/

@end
