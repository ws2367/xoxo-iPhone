//
//  BIDNameAndColorCell.h
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BigPostTableViewCellDelegate;

@interface BigPostTableViewCell : UITableViewCell


@property (nonatomic, weak) id<BigPostTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSArray *entities;
@property (copy, nonatomic) NSString *content;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) UIImage *image;


- (void)swipeRight;
- (void)swipeLeft;
-(void) setDateToShow:(NSString *)dateToShow;
-(void) setCellWithImage:(UIImage *)photo Entities:(NSArray *)entities Content:(NSString *)content CommentNum:(NSInteger *)commentNum FollowNum:(NSInteger *)followNum atDate:(NSDate *)date;

@end


@protocol BigPostTableViewCellDelegate <NSObject>

@required

- (void) CellPerformViewPost:(id)sender;
- (void) sharePost:(id)sender;
- (void) reportPost:(id)sender;
- (void) followPost:(id)sender;
- (void) commentPost:(id)sender;

@end
