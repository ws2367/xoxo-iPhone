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

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setHateNum:(NSInteger)hateNum{
    _hateNum = hateNum;
    _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];

    _hated = false;
    [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];

}

- (void) setLikeNum:(NSInteger)likeNum{
    _likeNum = likeNum;
    _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];

    _liked = false;
    [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
}

-(void) setContent:(NSString *)content{
    _content = [content copy];
    [_commentButton setTitle:_content forState:UIControlStateNormal];
    _commentButton.titleLabel.numberOfLines = 3;
    _commentButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _commentButton.titleLabel.font = [UIFont fontWithName:@"American Typewriter" size:11];
}

-(void)setLevelNum:(NSInteger)levelNum{
    _levelNum = levelNum + 1;
    [_numLabel setText:[NSString stringWithFormat:@"%d", _levelNum]];
}

@end
