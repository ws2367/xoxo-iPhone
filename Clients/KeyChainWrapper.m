//
//  KeyChainWrapper.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "KeyChainWrapper.h"

// AWS credentials
static NSString *AWSAccessKey = nil;
static NSString *AWSSecretKey = nil;
static NSString *AWSSecurityToken = nil;
static NSString *AWSExpiration = nil;

// Moose server credentials
static NSString *SessionToken = nil;

// FB credentials
static NSString *FBUserID = nil;

// Device token
static NSData *deviceToken = nil;

@implementation KeyChainWrapper

+(void)storeFBUserID:(NSString *)fbUserID
{
    if (fbUserID != nil) {
        FBUserID = [NSString stringWithString:fbUserID];
    }
}

+(NSString *)FBUserID
{
    return FBUserID;
}

+(BOOL)isFBUserIDValid
{
    if (FBUserID == nil || [FBUserID isEqualToString:@""]){
        return false;
    } else {
        return true;
    }
}

+(bool)areAWSCredentialsExpired
{
    AMZLogDebug(@"areAWSCredentialsExpired");
    
    NSString *expiration = AWSExpiration;
    if (expiration == nil) {
        return YES;
    }
    else {
        NSDate *expirationDate = [Utility DateForRFC3339DateTimeString:expiration];
        return [KeyChainWrapper isExpired:expirationDate];
    }
    
}

+(bool)isExpired:(NSDate *)date
{
    // if expiration is coming in fifteen minutes, let's renew it!
    NSDate *soon = [NSDate dateWithTimeIntervalSinceNow:(15 * 60)];
    
    if ( [soon compare:date] == NSOrderedDescending) {
        return YES;
    }
    else {
        return NO;
    }
}

/*
+(void)registerDeviceId:(NSString *)uid andKey:(NSString *)key
{
    UID = [NSString stringWithString:uid];
    Key = [NSString stringWithString:key];
    
    //[KeyChainWrapper storeValueInKeyChain:uid forKey:kKeychainUidIdentifier];
    //[KeyChainWrapper storeValueInKeyChain:key forKey:kKeychainKeyIdentifier];
}
 
+(NSString *)getKeyForDevice
{
    return Key;
}

+(NSString *)getUidForDevice
{
    return UID;
}
*/

+(void)storeSessionToken:(NSString *)theSessionToken{
    SessionToken = [NSString stringWithString:theSessionToken];
}

+(NSString *)getSessionTokenForUser
{
    return SessionToken;
}

+(BOOL) isSessionTokenValid
{
    if (SessionToken == nil || [SessionToken isEqualToString:@""]){
        return false;
    } else {
        return true;
    }
}

+(AmazonCredentials *)getAWSCredentialsFromKeyChain
{
    if ((AWSAccessKey != nil) && (AWSSecretKey != nil) && (AWSSecurityToken != nil)) {
        if (![KeyChainWrapper areAWSCredentialsExpired]) {
            AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:AWSAccessKey withSecretKey:AWSSecretKey];
            credentials.securityToken = AWSSecurityToken;
            
            return credentials;
        }
    }

    return nil;
}


+(void)storeCredentialsInKeyChain:(NSString *)theAWSAccessKey secretKey:(NSString *)theAWSSecretKey
                    securityToken:(NSString *)theAWSSecurityToken expiration:(NSString *)theAWSExpirationDate{
    
    if (theAWSAccessKey != nil && theAWSSecretKey != nil && theAWSSecurityToken != nil && theAWSExpirationDate != nil) {
        AWSAccessKey = [NSString stringWithString:theAWSAccessKey];
        AWSSecretKey = [NSString stringWithString:theAWSSecretKey];
        AWSSecurityToken = [NSString stringWithString:theAWSSecurityToken];
        AWSExpiration = [NSString stringWithString:theAWSExpirationDate];
    }
    /*
    [KeyChainWrapper storeValueInKeyChain:theAWSAccessKey forKey:kKeychainAWSAccessKeyIdentifier];
    [KeyChainWrapper storeValueInKeyChain:theAWSSecretKey forKey:kKeychainAWSSecretKeyIdentifier];
    [KeyChainWrapper storeValueInKeyChain:theAWSSecurityToken forKey:kKeychainAWSSecrutiyTokenIdentifier];
    [KeyChainWrapper storeValueInKeyChain:theAWSExpirationDate forKey:kKeychainAWSExpirationDateIdentifier];
     */
   
}

+(void)storeDeviceToken:(NSData *)theDeviceToken
{
    deviceToken = [NSData dataWithData:theDeviceToken];
}

+(NSData *)deviceToken
{
    return deviceToken;
}


+(void)cleanUpCredentials{
    // AWS credentials
    AWSAccessKey = nil;
    AWSSecretKey = nil;
    AWSSecurityToken = nil;
    AWSExpiration = nil;
    
    // Moose server credentials
    SessionToken = nil;
    
    // FB credentials
    FBUserID = nil;
}

@end
