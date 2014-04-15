//
//  MultiplePeoplePickerViewController.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/15/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MultiplePeoplePickerViewControllerDelegate;


@interface MultiplePeoplePickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<MultiplePeoplePickerViewControllerDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *senderIndexPath;

@end


@protocol MultiplePeoplePickerViewControllerDelegate <NSObject>

@required

- (void) donePickingMutiplePeople:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath;

@end
