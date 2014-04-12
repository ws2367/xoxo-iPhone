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

typedef void (^RKFailureBlock)(RKObjectRequestOperation *, NSError *);
typedef void (^RKSuccessBlock)(RKObjectRequestOperation *, RKMappingResult *);

+ (RKFailureBlock) failureBlockWithAlertMessage:(NSString *)message;

+ (RKFailureBlock) failureBlockWithAlertMessage:(NSString *)message block:(void (^)(void))callbackBlock;

+ (RKSuccessBlock) successBlockWithDebugMessage:(NSString *)message block:(void (^)(void))callbackBlock;

+ (void) generateAlertWithMessage:(NSString *)message
                            error:(NSError *)error;

+ (NSString *)getDateToShow:(NSDate *)date;

+ (void)saveToPersistenceStore:(NSManagedObjectContext *)context failureMessage:(NSString *)failureMessage;

+ (NSDictionary *)getTabBarItemSelectedFontDictionary;
+ (NSDictionary *)getTabBarItemUnselectedFontDictionary;
+ (NSDictionary *)getCommentNumberFontDictionary;
+ (NSDictionary *)getFollowNumberFontDictionary;
+ (NSDictionary *)getMultiPostsNameFontDictionary;
+ (NSDictionary *)getMultiPostsContentFontDictionary;
+ (NSDictionary *)getMultiPostsDateFontDictionary;
+ (NSDictionary *)getViewPostDisplayEntityFontDictionary;
+ (NSDictionary *)getViewPostDisplayInstitutionFontDictionary;
+ (NSDictionary *)getViewPostDisplayContentFontDictionary;
+ (NSDictionary *)getViewPostDisplayCommentFontDictionary;
+ (NSDictionary *)getLoginViewTitleDescriptionFontDictionary;
+ (NSDictionary *)getLoginViewContentDescriptionFontDictionary;
+ (NSDictionary *)getCreatePostViewAddFriendButtonFontDictionary;
+ (NSDictionary *)getCreatePostDisplayEntityFontDictionary;
+ (NSDictionary *)getCreatePostDisplayInstitutionFontDictionary;

@end
