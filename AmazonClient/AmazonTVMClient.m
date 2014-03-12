//
//  AmazonTVMClient.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "AmazonTVMClient.h"
#import "KeyChainWrapper.h"

@interface AmazonTVMClient ()

@property (retain, nonatomic) AFHTTPClient *httpClient;
@end



@implementation AmazonTVMClient

-(id)initWithEndpoint:(NSString *)theEndpoint{

    self = [super init];
    if (self) {
        self.endpoint = theEndpoint; // ignore endpoint domain issue now
        NSURL *url = [NSURL URLWithString:self.endpoint];
        // we are using AFTNETWOKRING 1.3.3.... not the latest one due to RestKit dependencies
        _httpClient = [AFHTTPClient clientWithBaseURL:url];
    }
    

    return self;
}

-(BOOL)getToken{
    //NSString *uid = [KeyChainWrapper getUidForDevice];
    //NSString *key = [KeyChainWrapper getKeyForDevice];
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];

    if (sessionToken == nil) {
        NSLog(@"User hasn't logged in");
        return false;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:sessionToken
                                                       forKey:@"auth_token"];
    NSLog(@"params: %@", params);
    
    NSDictionary* jsonFromData = nil;
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET"
                                                             path:@"S3Credentials"
                                                       parameters:params];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    jsonFromData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSLog(@"JSON: %@", jsonFromData);
    
    
    
    [KeyChainWrapper storeCredentialsInKeyChain:jsonFromData[@"ACCESS_KEY_ID"]
                                      secretKey:jsonFromData[@"SECRET_KEY"]
                                  securityToken:jsonFromData[@"SESSION_TOKEN"]
                                     expiration:jsonFromData[@"expires_at"]];
    
     //process response and store credentials in keychainwrapper
    
    return YES;
    
}
-(BOOL)login:(NSString *)username password:(NSString *)password{
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[username, password]
                                                       forKeys:@[@"user_name", @"password"]];
    
    NSLog(@"params: %@", params);
    NSDictionary* jsonFromData = nil;
    
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"POST"
                                                      path:@"users/sign_in"
                                                parameters:params];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error != nil || data == nil){
        NSLog(@"Can't log in!");
        return false;
    }
        
    jsonFromData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

    NSLog(@"JSON: %@", jsonFromData);
    
    if (jsonFromData[@"token"] != nil) {
        [KeyChainWrapper storeSessionToken:jsonFromData[@"token"]];
    } else {
        NSLog(@"Log in failed");
    }

    return YES;
}

//-(Response *)processRequest:(Request *)request responseHandler:(ResponseHandler *)handler{}
//-(NSString *)getEndpointDomain:(NSString *)originalEndpoint{}

@end
