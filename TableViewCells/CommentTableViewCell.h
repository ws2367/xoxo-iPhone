//
//  CommentCell.h
//  Cells
//
//  Created by WYY on 2013/11/24.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell
@property (copy, nonatomic) NSString *content;
@property (nonatomic, assign, getter=isLiked) BOOL liked;
@property (nonatomic, assign, getter=isHated) BOOL hated;
@property (nonatomic, assign) NSInteger likeNum;
@property (nonatomic, assign) NSInteger hateNum;
@property (nonatomic, assign) NSInteger levelNum;
@end
