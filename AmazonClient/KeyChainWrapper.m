//
//  KeyChainWrapper.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "KeyChainWrapper.h"

static NSString *AccessKey = nil;
static NSString *SecretKey = nil;
static NSString *SecurityToken = nil;
static NSString *Expiration = nil;

static NSString *UID = nil;
static NSString *Username = nil;
static NSString *Key = nil;

static NSString *SessionToken = nil;

@implementation KeyChainWrapper


+(bool)areCredentialsExpired
{
    AMZLogDebug(@"areCredentialsExpired");
    
    NSString *expiration = Expiration;
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
    
    NSLog(@"Expiration: %@, Time now: %@", date, [NSDate dateWithTimeIntervalSinceNow:0]);
    
    if ( [soon compare:date] == NSOrderedDescending) {
        return YES;
    }
    else {
        return NO;
    }
}


+(void)registerDeviceId:(NSString *)uid andKey:(NSString *)key
{
    UID = [NSString stringWithString:uid];
    Key = [NSString stringWithString:key];
    
    //[KeyChainWrapper storeValueInKeyChain:uid forKey:kKeychainUidIdentifier];
    //[KeyChainWrapper storeValueInKeyChain:key forKey:kKeychainKeyIdentifier];
}

+(void)storeUsername:(NSString *)theUsername
{
    Username = [NSString stringWithString:theUsername];
    
    //[KeyChainWrapper storeValueInKeyChain:theUsername forKey:kKeychainUsernameIdentifier];
}

+(NSString *)username
{
    return Username;
}

+(void)storeSessionToken:(NSString *)theSessionToken{
    SessionToken = [NSString stringWithString:theSessionToken];
}

+(NSString *)getSessionTokenForUser
{
    return SessionToken;
}

+(NSString *)getKeyForDevice
{
    return Key;
}

+(NSString *)getUidForDevice
{
    return UID;
}

+(AmazonCredentials *)getCredentialsFromKeyChain
{
    if ((AccessKey != nil) && (SecretKey != nil) && (SecurityToken != nil)) {
        if (![KeyChainWrapper areCredentialsExpired]) {
            AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:AccessKey withSecretKey:SecretKey];
            credentials.securityToken = SecurityToken;
            
            return credentials;
        }
    }

    return nil;
}


+(void)storeCredentialsInKeyChain:(NSString *)theAccessKey secretKey:(NSString *)theSecretKey
                    securityToken:(NSString *)theSecurityToken expiration:(NSString *)theExpirationDate{
    
    
    AccessKey = [NSString stringWithString:theAccessKey];
    SecretKey = [NSString stringWithString:theSecretKey];
    SecurityToken = [NSString stringWithString:theSecurityToken];
    Expiration = [NSString stringWithString:theExpirationDate];
    
    /*
    [KeyChainWrapper storeValueInKeyChain:theAccessKey forKey:kKeychainAccessKeyIdentifier];
    [KeyChainWrapper storeValueInKeyChain:theSecretKey forKey:kKeychainSecretKeyIdentifier];
    [KeyChainWrapper storeValueInKeyChain:theSecurityToken forKey:kKeychainSecrutiyTokenIdentifier];
    [KeyChainWrapper storeValueInKeyChain:theExpirationDate forKey:kKeychainExpirationDateIdentifier];
     */
   
}

+(void)storeValueInKeyChain:(NSString *)value forKey:(NSString *)key
{
    

}


@end
