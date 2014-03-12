//
//  AmazonClientManager.m
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


#import "AmazonClientManager.h"
#import "KeyChainWrapper.h"
//#import "Response.h"

#import <AWSRuntime/AWSRuntime.h>

//#import "KeyChainWrapper.h"

static AmazonS3Client *s3  = nil;
static AmazonTVMClient *tvm = nil;

@implementation AmazonClientManager

+(void)setup:(NSString *)accessKey secretKey:(NSString *)secretKey securityToken:(NSString *)token expiration:(NSString *)expiration
{
    [KeyChainWrapper storeCredentialsInKeyChain:accessKey secretKey:secretKey securityToken:token expiration:expiration];
}

+(AmazonS3Client *)s3
{
    [AmazonClientManager validateCredentials];
    return s3;
}

+(AmazonTVMClient *)tvm
{
    if (tvm == nil) {
        tvm = [[AmazonTVMClient alloc] initWithEndpoint:TOKEN_VENDING_MACHINE_URL];
    }
    
    return tvm;
}

+(bool)isLoggedIn
{
    return ([KeyChainWrapper getSessionTokenForUser] != nil);
}

+(BOOL)login:(NSString *)username password:(NSString *)password
{
    return [[AmazonClientManager tvm] login:username password:password];
}

+(BOOL)validateCredentials
{
    BOOL succeeded = NO;
    
    if ([KeyChainWrapper areCredentialsExpired])
    {
        succeeded = [[AmazonClientManager tvm] getToken];
        if (succeeded)
        {
            [AmazonClientManager initClient];
        }
    }
    
    else if (s3 == nil)
    {
        @synchronized(self)
        {
            if (s3 == nil)
            {
                [AmazonClientManager initClient];
            }
        }
    }
    
    return succeeded;
}

+(void)initClient
{
    NSLog(@"init client");
    AmazonCredentials *credentials = [KeyChainWrapper getCredentialsFromKeyChain];
    
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
