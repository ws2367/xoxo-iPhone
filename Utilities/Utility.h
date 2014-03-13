//
//  Utility.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/20/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

// in case you don't know, class methods are prefixed by plus sign (+)
+ (BOOL) compareUIColorBetween:(UIColor *)colorA and:(UIColor *)colorB;
+ (NSString *) getUUID;
+ (NSDate *)DateForRFC3339DateTimeString:(NSString *)rfc3339datestring;

//void (^failureAlert)(RKOperationRequestOperation *, NSError *);



@end
