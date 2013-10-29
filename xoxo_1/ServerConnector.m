//
//  ServerConnector.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 10/28/13.
//  Copyright (c) 2013 WYY. All rights reserved.
//

#import "ServerConnector.h"

@implementation ServerConnector

- (id)initWithURL:(NSString *)urlInString_
             verb:(NSString *)verb_
      requestType:(NSString *)requestType_
      responseType:(NSString *)responseType_
      timeoutInterval:(int)timeoutInterval_{
 
    
    //Consider not allocating spaces for NSString....
    _url          = [NSURL URLWithString:urlInString_];
    _verb         = [[NSString alloc] initWithString:verb_];
    _requestType  = [[NSString alloc] initWithString:requestType_];
    _responseType = [[NSString alloc] initWithString:responseType_];
    _timeoutInterval = timeoutInterval_;
    
    return self;
}

- (NSArray *) sendJSONGetJSONArray:(NSDictionary *)requestBody
{
    NSData *data;
    NSError *reqError = nil;
    
    if([NSJSONSerialization isValidJSONObject:requestBody]){
        data = [NSJSONSerialization dataWithJSONObject:requestBody options:NSJSONWritingPrettyPrinted error:&reqError];
    } else {
        NSLog(@"The request body is invalid");
    }
    
    if(reqError != nil){
        NSLog(@"Failed to serialize the NSDictionary!");
    }
    
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:_url
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:_timeoutInterval];
    
    [request setHTTPMethod:_verb];
    [request setValue:_requestType  forHTTPHeaderField:@"Content-type"];
    [request setValue:_responseType forHTTPHeaderField:@"Accept"];

    [request setHTTPBody:data];
    
    NSURLResponse *response = nil;
    NSError *resError = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&resError];
    
    if(resError != nil){
        NSLog(@"%@", [resError localizedDescription]);
    }

    if(result != nil){
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&reqError];
        return jsonArr;
    }
    else{
        NSLog(@"It is nill!!!");
        return nil;
    }
    
}

@end
