//
//  SettingViewController.h
//  Cells
//
//  Created by Iru on 3/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MultiplePeoplePickerViewController.h"

@protocol SettingViewControllerDelegate;


@interface SettingViewController : UIViewController <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, MultiplePeoplePickerViewControllerDelegate>
@property (nonatomic, weak) id<SettingViewControllerDelegate> delegate;


@end


@protocol SettingViewControllerDelegate <NSObject>

-(void)userLogOut;

@end