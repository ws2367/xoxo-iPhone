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
const int TABBAR_HEIGHT = 44;
const float TIMESTAMP_MAX = 2147483647.000;
const int NAVIGATION_BAR_CUT_DOWN_HEIGHT = 64;

NSString *const TOKEN_VENDING_MACHINE_URL = @"http://localhost:3000/v1/";

// Let's let the URL end with '/' so later in response descriptors or routes we don't need to prefix path patterns with '/'
// Remeber, evaluation of path patterns against base URL could be surprising.
NSString *const BASE_URL = @"http://localhost:3000/v1/";

NSString *const S3BUCKET_NAME = @"moose-photos";

NSString *const bigPostCellIdentifier = @"bigPostCell";
NSString *const commentCellIdentifier = @"commentCell";
NSString *const entityCellIdentifier  = @"entityCell";

@implementation Constants
@end
