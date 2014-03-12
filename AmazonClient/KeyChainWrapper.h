//
//  KeyChainWrapper.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <AWSRuntime/AWSRuntime.h>

@interface KeyChainWrapper : NSObject

+(bool)areCredentialsExpired;
+(AmazonCredentials *)getCredentialsFromKeyChain;
+(void)storeCredentialsInKeyChain:(NSString *)theAccessKey secretKey:(NSString *)theSecretKey securityToken:(NSString *)theSecurityToken expiration:(NSString *)theExpirationDate;

+(void)storeUsername:(NSString *)theUsername;
+(NSString *)username;

+(void)storeSessionToken:(NSString *)theSessionToken;
+(NSString *)getSessionTokenForUser;

//+(NSString *)getValueFromKeyChain:(NSString *)key;
//+(void)storeValueInKeyChain:(NSString *)value forKey:(NSString *)key;

+(void)registerDeviceId:(NSString *)uid andKey:(NSString *)key;
+(NSString *)getUidForDevice;
+(NSString *)getKeyForDevice;

+(bool)isExpired:(NSDate *)date;

//+(OSStatus)wipeKeyChain;
//+(OSStatus)wipeCredentialsFromKeyChain;
//+(NSMutableDictionary *)createKeychainDictionaryForKey:(NSString *)key;

@end
