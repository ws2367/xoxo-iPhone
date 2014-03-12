//
//  AmazonTVMClient.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/10/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmazonTVMClient : NSObject

@property (nonatomic, retain) NSString *endpoint;
//@property (nonatomic, retain) NSString *appName;
//@property (nonatomic) bool             useSSL;

-(id)initWithEndpoint:(NSString *)endpoint;
-(BOOL)getToken;
-(BOOL)login:(NSString *)username password:(NSString *)password;
//-(Response *)processRequest:(Request *)request responseHandler:(ResponseHandler *)handler;
//-(NSString *)getEndpointDomain:(NSString *)originalEndpoint;


@end
