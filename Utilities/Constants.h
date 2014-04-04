//
//  Constants.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/20/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MSDebug NSLog
#define MSError NSLog

// initialized in .m file
// extern can be put inside interface as well
extern const float ANIMATION_KEYBOARD_DURATION;
extern const float ANIMATION_DURATION;
extern const float ANIMATION_DELAY;
extern const int HEIGHT;
extern const int WIDTH;
extern const int TABBAR_HEIGHT;
extern const int UPPER_AREA_HEIGHT;
extern const float TIMESTAMP_MAX;
extern const int NAVIGATION_BAR_CUT_DOWN_HEIGHT;
extern const int VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT;
extern const int VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT;
extern const int VIEW_POST_NAVIGATION_BAR_HEIGHT;


extern NSString *const S3BUCKET_NAME;

extern NSString *const TOKEN_VENDING_MACHINE_URL;
extern NSString *const BASE_URL;


extern NSString *const bigPostCellIdentifier;
extern NSString *const commentCellIdentifier;
extern NSString *const entityCellIdentifier;

@interface Constants : NSObject
@end
