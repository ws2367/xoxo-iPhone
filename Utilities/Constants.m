//
//  Constants.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/20/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Constants.h"

// settin externs can be put inside implementation as well
const float ANIMATION_KEYBOARD_DURATION = 0.3;
const float ANIMATION_DURATION = 0.4;
const float ANIMATION_DELAY = 0.0;
const int HEIGHT = 568;
const int WIDTH = 320;
const int TABBAR_HEIGHT = 50;
const int UPPER_AREA_HEIGHT = 20;
const float TIMESTAMP_MAX = 2147483647.000;
const int NAVIGATION_BAR_CUT_DOWN_HEIGHT = 64;
const int VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT = 250;
const int VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT = 39;
const int VIEW_POST_DISPLAY_BUTTON_BAR_HEIGHT = 45;
const int VIEW_POST_DISPLAY_COMMENT_HEIGHT = 60;
const int VIEW_POST_NAVIGATION_BAR_HEIGHT = 63;
const int BIG_POSTS_CELL_HEIGHT = 250;
const int HEIGHT_TO_DISCRIMINATE = 500;
const int MY_POST_TABBAR_HEIGHT = 45;




// Let's let the URL end with '/' so later in response descriptors or routes we don't need to prefix path patterns with '/'
// Remeber, evaluation of path patterns against base URL could be surprising.
//

#define PRODUCTION_SERVER @"107.170.232.66"
#define LOCAL_HOST        @"localhost"
#define STAGING_SERVER    @"107.170.210.8"
#define TESTING_SERVER    @"107.170.193.248"

#define URLMake(IP) (@"http://" IP @":3000/v1/")

#ifdef DEBUG
    NSString *const FL_APP_KEY = @"MQ724NMDYQJMTQKFB4DD";
    NSString *const BUILD_MODE = @"DEBUG mode";
    NSString *const BASE_URL = URLMake(TESTING_SERVER);

#else
    NSString *const FL_APP_KEY = @"YF2MB9Y24R2M664N6JT8";
    NSString *const BUILD_MODE = @"RELEASE mode";
    NSString *const BASE_URL = URLMake(PRODUCTION_SERVER);

#endif


NSString * S3BUCKET_NAME = @"undefined";

NSString *const bigPostCellIdentifier = @"bigPostCell";
NSString *const commentCellIdentifier = @"commentCell";
NSString *const entityCellIdentifier  = @"entityCell";
NSString *const viewPostDisplayImageCellIdentifier = @"viewPostDisplayImageCell";
NSString *const viewPostDisplayEntityCellIdentifier = @"viewPostDisplayEntityCell";
NSString *const viewPostDisplayCommentCellIdentifier = @"viewPostDisplayCommentCell";
NSString *const viewPostDisplayButtonBarCellIdentifier = @"viewPostDisplayButtonBarCell";
NSString *const viewPostDisplayContentCellIdentifier = @"viewPostDisplayContentCell";

//Flurry constants
NSString *const FL_IS_FINISHED = @"Is_Finished";
NSString *const FL_YES = @"YES";
NSString *const FL_NO = @"NO";

NSString *REMOTE_NOTIF_POST_ID = NULL;


@implementation Constants

+ (void)setS3BucketName:(NSString *)name{
    S3BUCKET_NAME = [NSString stringWithString:name];
}

@end
