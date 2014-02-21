//
//  CommentCell.m
//  Cells
//
//  Created by WYY on 2013/11/24.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "CommentTableViewCell.h"

@interface CommentTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *likeValue;
@property (weak, nonatomic) IBOutlet UILabel *hateValue;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *hateButton;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end

@implementation CommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setCommentStr:(NSString *)commentStr{
    _commentStr = [commentStr copy];
    [_commentButton setTitle:_commentStr forState:UIControlStateNormal];
    
    _likeNum = 4;
    _hateNum = 3;
    _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];
    _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];
    
    _liked = false;
    _hated = false;
    [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
    [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];
}

-(void)setLevelNum:(NSInteger)levelNum{
    _levelNum = levelNum + 1;
    [_numLabel setText:[NSString stringWithFormat:@"%d", _levelNum]];
}

@end
