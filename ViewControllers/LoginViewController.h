//
//  LoginViewController.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/22/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <FBLoginViewDelegate, UINavigationControllerDelegate>

- (void) loginViewShowingLoggedOutUser:(FBLoginView *)loginView;

@end
