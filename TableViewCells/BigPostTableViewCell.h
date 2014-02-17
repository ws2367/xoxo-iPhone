//
//  BIDNameAndColorCell.h
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface BigPostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *entityButton;

@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *entity;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (copy, nonatomic) NSString *pic;
@property (nonatomic, assign, getter=isLiked) BOOL liked;
@property (nonatomic, assign, getter=isHated) BOOL hated;
@property (nonatomic, assign) NSInteger likeNum;
@property (nonatomic, assign) NSInteger hateNum;

@property (strong, nonatomic) IBOutlet UITextView *titleValue;
@property (strong, nonatomic) IBOutlet UIImageView *myPic;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *hateButton;
@property (strong, nonatomic) IBOutlet UILabel *likeValue;
@property (strong, nonatomic) IBOutlet UILabel *hateValue;
@property (strong, nonatomic) NSArray *entities;

- (void)symptomCellSwipeRight;
- (void)symptomCellSwipeLeft;

@end

