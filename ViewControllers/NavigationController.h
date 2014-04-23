//
//  navigationController.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/13/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationController : UINavigationController

-(void) userLogOut;
-(void) setUserName:(NSString *)userName;
-(NSString *) getUserName;
@end
