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
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) UIImage *image;


- (void)swipeRight;
- (void)swipeLeft;
-(void) setDateToShow:(NSString *)dateToShow;
-(void) setCellWithImage:(UIImage *)photo Entities:(NSArray *)entities Content:(NSString *)content CommentNum:(NSInteger *)commentNum FollowNum:(NSInteger *)followNum atDate:(NSDate *)date;

@end

