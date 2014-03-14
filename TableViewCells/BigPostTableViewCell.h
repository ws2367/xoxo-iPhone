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

//TODO: not sure what attributes should be used for image
@property (strong, nonatomic) UIImage *image;
//@property (nonatomic, assign) NSInteger likeNum;
//@property (nonatomic, assign) NSInteger hateNum;
//@property (nonatomic, assign, getter=isLiked) BOOL liked;
//@property (nonatomic, assign, getter=isHated) BOOL hated;


- (void)swipeRight;
- (void)swipeLeft;

@end

