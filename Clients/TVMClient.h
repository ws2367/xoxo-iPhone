//
//  TVMClient.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TVMClientDelegate;

@interface TVMClient : NSObject <UIAlertViewDelegate>

@property (nonatomic, weak) id<TVMClientDelegate> delegate;

@property (nonatomic, retain) NSString *endpoint;

-(id)initWithEndpoint:(NSString *)endpoint;
-(BOOL)getToken;
-(void)login:(NSString *)FBAccessToken;
-(BOOL)logout;
-(void)checkLetterPrompt;

@end

@protocol TVMClientDelegate <NSObject>

@required

- (void) TVMLoggedIn;
- (void) TVMSignedUp;
- (void) TVMLoggingInFailed;

@end
