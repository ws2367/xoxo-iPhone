//
//  KeyChainWrapper.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <AWSRuntime/AWSRuntime.h>

@interface KeyChainWrapper : NSObject

+(bool)areAWSCredentialsExpired;
+(AmazonCredentials *)getAWSCredentialsFromKeyChain;
+(void)storeCredentialsInKeyChain:(NSString *)theAccessKey
                        secretKey:(NSString *)theSecretKey
                    securityToken:(NSString *)theSecurityToken
                       expiration:(NSString *)theExpirationDate;

+(void)storeSessionToken:(NSString *)theSessionToken;
+(NSString *)getSessionTokenForUser;
+(BOOL) isSessionTokenValid;

+(void)storeFBUserID:(NSString *)fbUserID;
+(BOOL)isFBUserIDValid;
+(NSString *)FBUserID;

+(void)cleanUpCredentials;
//+(NSString *)getValueFromKeyChain:(NSString *)key;
//+(void)storeValueInKeyChain:(NSString *)value forKey:(NSString *)key;
//+(void)registerDeviceId:(NSString *)uid andKey:(NSString *)key;
//+(NSString *)getUidForDevice;
//+(NSString *)getKeyForDevice;

//+(OSStatus)wipeKeyChain;
//+(OSStatus)wipeCredentialsFromKeyChain;
//+(NSMutableDictionary *)createKeychainDictionaryForKey:(NSString *)key;

@end
