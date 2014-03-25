//
//  Utility.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/20/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Utility.h"

@implementation Utility

// in case you don't know, class methods are prefixed by plus sign (+)
+ (BOOL) compareUIColorBetween:(UIColor *)colorA and:(UIColor *)colorB
{
    CGFloat redA, redB, greenA, greenB, blueA, blueB, alphaA, alphaB;
    [colorA getRed:&redA green:&greenA blue:&blueA alpha:&alphaA];
    [colorB getRed:&redB green:&greenB blue:&blueB alpha:&alphaB];
    
    if (redA == redB && greenA == greenB && blueA == blueB && alphaA == alphaB)
        return FALSE;
    else
        return TRUE;
}

+ (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}


+ (NSDate *)DateForRFC3339DateTimeString:(NSString *)rfc3339datestring
{
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate *date = [rfc3339DateFormatter dateFromString:rfc3339datestring];
    
    return date;
}

+ (RKFailureBlock) generateFailureAlertWithMessage:(NSString *)message
{
    return ^(RKObjectRequestOperation *operation, NSError *error){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    };
}

+ (void) generateAlertWithMessage:(NSString *)message error:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];

}

@end
