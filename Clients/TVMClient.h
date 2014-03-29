//
//  TVMClient.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TVMClient : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) NSString *endpoint;
//@property (nonatomic) bool             useSSL;

-(id)initWithEndpoint:(NSString *)endpoint;
-(BOOL)getToken;
-(BOOL)login:(NSString *)FBAccessToken;
-(BOOL)logout;



@end
