//
//  ClientManager.h
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


#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>

#import "TVMClient.h"
#import "S3RequestResponder.h"

@interface ClientManager : NSObject <S3RequestResponderDelegate>

+(void)setup:(NSString *)accessKey secretKey:(NSString *)secretKey securityToken:(NSString *)token expiration:(NSString *)expiration;

// S3 Clients
+(AmazonS3Client *)s3;
+ (void)cancelAllS3Requests;
+ (void)loadPhotosForPost:(Post *)post;

+(bool)isLoggedIn;
+(void)login:(NSString *)FBAccessToken delegate:(id<TVMClientDelegate>)delegate;
+(BOOL)logout;
+(BOOL)validateCredentials;

+(void)checkLetterPrompt;

+ (void)sendBadgeNumber:(NSInteger)number;

// Note that ClientManager is called to send device token twice. One is called here. Another one is called when
// TVMClient receives session token from moose server. The reason is because we don't konw which is received first -
// device token or session token. Therefore, we call ClientManager to send device token when the app receives either of them
// and let ClientManager to check if both are ready. If yes, ClientManager sends to device token to moose server.
+ (void)sendDeviceToken;

@end

