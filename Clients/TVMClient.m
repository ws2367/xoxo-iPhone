//
//  TVMClient.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "TVMClient.h"
#import "KeyChainWrapper.h"
#import "ClientManager.h"

@interface TVMClient (){
    NSInteger tryAgainButtonIndex;
}

@property (retain, nonatomic) AFHTTPClient *httpClient;
@property (strong, nonatomic) NSString *FBAccessToken;

@end



@implementation TVMClient

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
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"User hasn't logged in");
        return false;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSDictionary *params = [NSDictionary dictionaryWithObject:sessionToken
                                                       forKey:@"auth_token"];
    
    NSDictionary* jsonFromData = nil;
    BOOL success = [self sendSynchronousRequestWithClient:_httpClient
                                                   method:@"GET"
                                                     path:@"S3Credentials"
                                               parameters:params
                                                 response:&jsonFromData
                                                 errorLog:@"Can't retrieve S3 credentials via server!"];
    if (!success) {
        return false;
    }
    
    
    [KeyChainWrapper storeCredentialsInKeyChain:jsonFromData[@"ACCESS_KEY_ID"]
                                      secretKey:jsonFromData[@"SECRET_KEY"]
                                  securityToken:jsonFromData[@"SESSION_TOKEN"]
                                     expiration:jsonFromData[@"expires_at"]];
    
     //process response and store credentials in keychainwrapper
    
    return true;
    
}

-(void)checkLetterPrompt
{
    [_httpClient getPath:@"letters/check" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *response = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:nil];
        NSString *letter = [response objectForKey:@"letter"];
        if (letter) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Letter from Yours"
                                                                message:letter
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MSError(@"Failed to check letter prompt");
    }];
}

#pragma mark -
#pragma mark UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == tryAgainButtonIndex) {
        MSDebug(@"Try to log in again!");
        [self login:_FBAccessToken];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TVMLoggingInFailed)]) {
            [self.delegate TVMLoggingInFailed];
        } else {
            MSError(@"TVMClient's delegation is not set!");
        }
    }
}


-(void)login:(NSString *)FBAccessToken{
    _FBAccessToken = [NSString stringWithString:FBAccessToken];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:FBAccessToken
                                                                     forKey:@"fb_access_token"];
    NSLog(@"Before login: %@", params);
    
    [_httpClient postPath:@"users/sign_in" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self handleLoggedIn:(NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:nil]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFailedToLogIn:error];
    }];
}

- (void)handleLoggedIn:(NSDictionary *)response
{
    NSString *token = [response objectForKey:@"token"];
    NSString *bucketName = [response objectForKey:@"bucket_name"];
    NSString *signup = [response objectForKey:@"signup"];
    
    if (token != nil && bucketName != nil && signup != nil) {
        [KeyChainWrapper storeSessionToken:token];
        [Constants setS3BucketName:bucketName];
        MSDebug(@"Auth token: %@", token);
        MSDebug(@"Bucket name: %@", S3BUCKET_NAME);
        MSDebug(@"Signup: %@", signup);
        
        [ClientManager sendDeviceToken];
        if ([signup isEqualToString:@"true"]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(TVMSignedUp)]) {
                [self.delegate TVMSignedUp];
            } else {
                MSError(@"TVMClient's delegate method TVMSignedUp is not set!");
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(TVMLoggedIn)]) {
                [self.delegate TVMLoggedIn];
            } else {
                MSError(@"TVMClient's delegate method TVMLoggedIn is not set!");
            }
        }
    } else {
        MSError(@"Login request sent successfully, but either token, bucket_name or signup is not returned");
    }

}

- (void)handleFailedToLogIn:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    tryAgainButtonIndex = [alert addButtonWithTitle:@"Try again!"];
    [alert show];
}

- (BOOL)logout
{
    if ([KeyChainWrapper isSessionTokenValid]) {
        NSDictionary *params = [NSDictionary dictionaryWithObject:[KeyChainWrapper getSessionTokenForUser]
                                                           forKey:@"authentication_token"];
        
        [self sendSynchronousRequestWithClient:_httpClient
                                        method:@"DELETE"
                                          path:@"users/sign_out"
                                    parameters:params
                                      response:nil
                                      errorLog:@"Can't log out!"];
    }
    
    return YES;

}


- (BOOL) sendSynchronousRequestWithClient:(AFHTTPClient *)client
                                   method:(NSString *)method
                                     path:(NSString *)path
                               parameters:(NSDictionary *)params
                                 response:(NSDictionary **)response
                                 errorLog:(NSString *)errorLog
{
    NSMutableURLRequest *request = [client requestWithMethod:method path:path parameters:params];
    
    NSHTTPURLResponse *_response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&_response
                                                     error:&error];
    
    if (error != nil || data == nil || _response.statusCode != 200){
        NSLog(@"%@", errorLog);
        return false;
    }

    if (response != nil) {
        (*response) = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:nil];
    }
    return true;
}

@end
