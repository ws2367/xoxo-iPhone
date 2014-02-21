//
//  BIDNameAndColorCell.h
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigPostTableViewCell : UITableViewCell

@property (strong, nonatomic) NSArray *entities;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *pic;
@property (nonatomic, assign) NSInteger likeNum;
@property (nonatomic, assign) NSInteger hateNum;
@property (nonatomic, assign, getter=isLiked) BOOL liked;
@property (nonatomic, assign, getter=isHated) BOOL hated;

// so the target and action can be set from outside
@property (weak, nonatomic) IBOutlet UIButton *entityButton;

- (void)swipeRight;
- (void)swipeLeft;

@end

