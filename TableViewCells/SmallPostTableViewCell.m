//
//  SmallPostTableViewCell.m
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//
/*
#import "SmallPostTableViewCell.h"

@implementation SmallPostTableViewCell

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



- (void)setTitle:(NSString *)n
{
    if (![n isEqualToString:_title]) {
        _title = [n copy];
        NSRange stringRange = {0,65};
        if(_title.length > 65){
            _title = [_title substringWithRange:stringRange];
            _title = [_title stringByAppendingFormat:@"..."];
        }
        _titleValue.text = _title;
    }
    
    _likeNum = 4;
    _hateNum = 3;
    _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];
    _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];
    
    _liked = false;
    _hated = false;
    [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
    [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];
    
}
- (void)setEntity:(NSString *)c
{
    if (![c isEqualToString:_entity]) {
        _entity = [c copy];
        _entityValue.text = _entity;
    }
}

- (void)setPic:(NSString *)c
{
    if (![c isEqualToString:_pic]) {
        _pic = [c copy];
        _myPic.image = [UIImage imageNamed:_pic];
    }
}

- (IBAction)likeButtonPressed: (id)sender {
    if([self isLiked]){
        _liked = false;
        _likeNum--;
        _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];
        [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
    }else{
        _liked = true;
        _likeNum++;
        _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];
        [_likeButton setImage:[UIImage imageNamed:@"likeon"] forState:UIControlStateNormal];
    }
}


- (IBAction)hateButtonPressed: (id)sender {
    if([self isHated]){
        _hated = false;
        _hateNum--;
        _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];
        [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];
    }else{
        _hated = true;
        _hateNum++;
        _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];
        [_hateButton setImage:[UIImage imageNamed:@"hateon"] forState:UIControlStateNormal];
    }
}

@end
 */
