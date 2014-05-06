//
//  LoginViewController.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/22/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TVMClient.h"

@interface LoginViewController : UIViewController <FBViewControllerDelegate, FBLoginViewDelegate,
                    UINavigationControllerDelegate, TVMClientDelegate>

- (void) logoutUser;
@end
