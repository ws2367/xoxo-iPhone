//
//  BIDNameAndColorCell.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BIDNameAndColorCell.h"

@implementation BIDNameAndColorCell{
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //[_likeButton setTitle:@"like!" forState:UIControlStateNormal];
        //_likeButton.imageView.image = [UIImage imageNamed:@"like"];
        //_hateButton.imageView.image = [UIImage imageNamed:@"hate"];
        //_likeButton.titleLabel.text = @"like!";
        //CGRectMake(17, 14, 238, 70)
                              //[path FILL];
       // UIBezierPath *path = [UIBezierPath BE`
        
//        CGRect nameLabelRect = CGRectMake(0, 5, 70, 15);
//        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameLabelRect];
//        nameLabel.textAlignment = NSTextAlignmentRight;
//        nameLabel.text = @"Name:";
//        nameLabel.font = [UIFont boldSystemFontOfSize:12];
//        [self.contentView addSubview: nameLabel];
//        CGRect colorLabelRect = CGRectMake(0, 26, 70, 15);
//        UILabel *colorLabel = [[UILabel alloc] initWithFrame:colorLabelRect];
//        colorLabel.textAlignment = NSTextAlignmentRight;
//        colorLabel.text = @"Color:";
//        colorLabel.font = [UIFont boldSystemFontOfSize:12];
//        [self.contentView addSubview: colorLabel];
//        CGRect nameValueRect = CGRectMake(80, 5, 200, 15);
//        _nameValue = [[UILabel alloc] initWithFrame:
//                      nameValueRect];
//        [self.contentView addSubview:_nameValue];
//        CGRect colorValueRect = CGRectMake(80, 25, 200, 15);
//        _colorValue = [[UILabel alloc] initWithFrame:
//                       colorValueRect];
//        [self.contentView addSubview:_colorValue];
//        // Initialization code
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
