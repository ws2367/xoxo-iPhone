//
//  ServerConnector.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 10/28/13.
//  Copyright (c) 2013 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerConnector : NSObject

@property(strong, nonatomic) NSURL *url;
@property(strong, nonatomic) NSString *verb;
@property(strong, nonatomic) NSString *requestType;
@property(strong, nonatomic) NSString *responseType;
@property(nonatomic) int timeoutInterval;

- (id)initWithURL:(NSString *)urlInString_
             verb:(NSString *)verb_
      requestType:(NSString *)requestType_
     responseType:(NSString *)responseType_
  timeoutInterval:(int)timeoutInterval_;


// A NSDictionary is given as a JSON.
// A NSArray of NSDictionaries is returned as a JSON array.
- (NSArray *) sendJSONGetJSONArray:(NSDictionary *)requestBody;

@end
