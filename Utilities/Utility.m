//
//  Utility.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/20/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Utility.h"
#import "UIColor+MSColor.h"

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

+ (void)saveToPersistenceStore:(NSManagedObjectContext *)context failureMessage:(NSString *)failureMessage{
    if ([context saveToPersistentStore:nil]) {
        MSDebug(@"Successfully saved to persistence store.");
    } else {
        NSLog(@"%@", failureMessage);
    }

}


+ (NSString *)getDateToShow:(NSDate *)date inWhole:(BOOL) inWhole;{
    if (inWhole) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger month = [components month];
        NSInteger year = [components year];
        NSInteger day = [components day];
        NSString *monthString = [Utility getMonthName:month];
        NSString *yearString = [NSString stringWithFormat: @"%d", (int)year];
        NSString *dayString = [NSString stringWithFormat:@"%d", (int)day];
        return [[[[monthString stringByAppendingString:@" "] stringByAppendingString:dayString ] stringByAppendingString:@", "] stringByAppendingString:yearString];
    }
    NSTimeInterval timedifference = -date.timeIntervalSinceNow;
    if(timedifference < 60){
        return @"now";
    }
    int yearCnt = floor(timedifference/YEAR_SECOND);
    if(yearCnt > 0){
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger month = [components month];
        NSInteger year = [components year];
        NSInteger day = [components day];
        NSString *monthString = [Utility getMonthName:month];
        NSString *yearString = [NSString stringWithFormat: @"%d", (int)year];
        NSString *dayString = [NSString stringWithFormat:@"%d", (int)day];
        return [[[[monthString stringByAppendingString:@" "] stringByAppendingString:dayString ] stringByAppendingString:@", "] stringByAppendingString:yearString];

    }
    int monthCnt = floor(timedifference/MONTH_SECOND);
    if(monthCnt > 0){
        NSString *monthString = [NSString stringWithFormat: @"%d", monthCnt];
        return [monthString stringByAppendingString:@"mo"];
    }
    int weekCnt = floor(timedifference/WEEK_SECOND);
    if(weekCnt > 0){
        NSString *weekString = [NSString stringWithFormat: @"%d", weekCnt];
        return [weekString stringByAppendingString:@"w"];
    }
    int dayCnt = floor(timedifference/DAY_SECOND);
    if(dayCnt > 0){
        NSString *dayString = [NSString stringWithFormat: @"%d", dayCnt];
        return [dayString stringByAppendingString:@"d"];
    }
    int hourCnt = floor(timedifference/HOUR_SECOND);
    if(hourCnt > 0){
        NSString *hourString = [NSString stringWithFormat: @"%d", hourCnt];
        return [hourString stringByAppendingString:@"h"];
    }
    int minCnt = floor(timedifference/MIN_SECOND);
    if(minCnt > 0){
        NSString *minString = [NSString stringWithFormat: @"%d", minCnt];
        return [minString stringByAppendingString:@"m"];
    }
    
    NSString *secString = [NSString stringWithFormat: @"%d", (int)timedifference];
    return [secString stringByAppendingString:@"s"];
    
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

+ (NSDictionary *)getTabBarItemSelectedFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:12],NSFontAttributeName, [UIColor colorForYoursWhite] ,NSForegroundColorAttributeName,nil];
}

+ (NSDictionary *)getViewPostDisplayContentDateFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:12],NSFontAttributeName, [UIColor colorForYoursLightGray] ,NSForegroundColorAttributeName,nil];
}

+ (NSDictionary *)getTabBarItemUnselectedFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:12],NSFontAttributeName, [UIColor colorForYoursTabBarUnselectedColor] ,NSForegroundColorAttributeName,nil];
}

+ (NSDictionary *)getCommentNumberFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:12],NSFontAttributeName, [UIColor colorForYoursBlue] ,NSForegroundColorAttributeName,nil];
}

+ (NSDictionary *)getFollowNumberFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:12],NSFontAttributeName, [UIColor colorForYoursOrange] ,NSForegroundColorAttributeName,nil];
}

+ (NSDictionary *)getMultiPostsNameFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-UltLtCn" size:35],NSFontAttributeName, [UIColor colorForYoursCyan] ,NSForegroundColorAttributeName,nil];
    


}
+ (NSDictionary *)getMultiPostsContentFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:17],NSFontAttributeName, [UIColor whiteColor] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getMultiPostsDateFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"Helvetica" size:15],NSFontAttributeName, [UIColor whiteColor] ,NSForegroundColorAttributeName,nil];
}

+ (NSDictionary *)getViewPostDisplayEntityFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:17],NSFontAttributeName, [UIColor blackColor] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getViewPostDisplayInstitutionFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:12],NSFontAttributeName, [UIColor colorForYoursGray] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getViewPostDisplayContentFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18],NSFontAttributeName, [UIColor colorForYoursGray] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getViewPostDisplayCommentFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:14],NSFontAttributeName, [UIColor colorForYoursDarkBlue] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getLoginViewTitleDescriptionFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:20],NSFontAttributeName, [UIColor colorForYoursWhite] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getLoginViewContentDescriptionFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16],NSFontAttributeName, [UIColor colorForYoursWhite] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getCreatePostViewAddFriendButtonFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16],NSFontAttributeName, [UIColor whiteColor] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getCreatePostDisplayEntityFontDictionary{
//    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:15],NSFontAttributeName, [UIColor blackColor] ,NSForegroundColorAttributeName,nil];
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeue" size:14],NSFontAttributeName, [UIColor blackColor] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getCreatePostDisplayInstitutionFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:10],NSFontAttributeName, [UIColor colorForYoursGray] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getNavigationBarTitleFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:19],NSFontAttributeName, [UIColor whiteColor] ,NSForegroundColorAttributeName,nil];
}
+ (NSDictionary *)getSettingButtonFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:19],NSFontAttributeName, [UIColor colorForYoursOrange] ,NSForegroundColorAttributeName,nil];
}

+ (NSDictionary *)getViewEntityInstitutionFontDictionary{
    return [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"HelveticaNeueLTStd-Roman" size:12],NSFontAttributeName, [UIColor colorForYoursWhite] ,NSForegroundColorAttributeName,nil];
}


@end
