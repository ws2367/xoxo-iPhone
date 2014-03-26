//
//  Utility.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/20/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Utility.h"

#define YEAR_SECOND 31556926
#define MONTH_SECOND 2629743
#define WEEK_SECOND 604800
#define DAY_SECOND 86400
#define HOUR_SECOND 3600
#define MIN_SECOND 60


@interface Utility(){
    
}
+ (NSString *)getMonthName:(NSInteger)month;
@end
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

+ (RKFailureBlock) failureBlockWithAlertMessage:(NSString *)message
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

+ (RKFailureBlock) failureBlockWithAlertMessage:(NSString *)message block:(void (^)(void))callbackBlock
{
    return ^(RKObjectRequestOperation *operation, NSError *error){
        if (callbackBlock) {callbackBlock();}
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    };
}

+ (RKSuccessBlock) successBlockWithDebugMessage:(NSString *)message block:(void (^)(void))callbackBlock
{
    return ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
        if (callbackBlock) {callbackBlock();}
        MSDebug(@"%@", message);
    };
}


+ (void) generateAlertWithMessage:(NSString *)message error:(NSError *)error
{
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:message
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:message
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
    }
    [alertView show];

}


+ (NSString *)getDateToShow:(NSDate *)date{
    
    NSTimeInterval timedifference = -date.timeIntervalSinceNow;
    if(timedifference < 5){
        return @"just now";
    }
    int yearCnt = floor(timedifference/YEAR_SECOND);
    if(yearCnt > 0){
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger month = [components month];
        NSInteger year = [components year];
        NSString *a = [Utility getMonthName:month];
        NSString *yearstring = [NSString stringWithFormat: @"%d", (int)year];
        return [[a stringByAppendingString:@" "] stringByAppendingString:yearstring];

    }
    int monthCnt = floor(timedifference/MONTH_SECOND);
    if(monthCnt > 0){
        NSString *monthString = [NSString stringWithFormat: @"%d", monthCnt];
        return [monthString stringByAppendingString:@"mo ago"];
    }
    int dayCnt = floor(timedifference/DAY_SECOND);
    if(dayCnt > 0){
        NSString *dayString = [NSString stringWithFormat: @"%d", dayCnt];
        return [dayString stringByAppendingString:@"d ago"];
    }
    int hourCnt = floor(timedifference/HOUR_SECOND);
    if(hourCnt > 0){
        NSString *hourString = [NSString stringWithFormat: @"%d", hourCnt];
        return [hourString stringByAppendingString:@"h ago"];
    }
    int minCnt = floor(timedifference/MIN_SECOND);
    if(minCnt > 0){
        NSString *minString = [NSString stringWithFormat: @"%d", minCnt];
        return [minString stringByAppendingString:@"m ago"];
    }
    
    NSString *secString = [NSString stringWithFormat: @"%d", (int)timedifference];
    return [secString stringByAppendingString:@"s ago"];
    
}

+ (NSString *)getMonthName:(NSInteger)month{
    switch ((int)month) {
        case 1:
            return @"Jan";
        case 2:
            return @"Feb";
        case 3:
            return @"Mar";
        case 4:
            return @"Apr";
        case 5:
            return @"May";
        case 6:
            return @"Jun";
        case 7:
            return @"Jul";
        case 8:
            return @"Aug";
        case 9:
            return @"Sep";
        case 10:
            return @"Oct";
        case 11:
            return @"Nov";
        case 12:
            return @"Dec";
        default:
            return @"Dec";
    }

}
@end
