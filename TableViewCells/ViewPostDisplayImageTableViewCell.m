//
//  ViewPostViewImageTableViewCell.m
//  Cells
//
//  Created by Iru on 4/3/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayImageTableViewCell.h"

@interface ViewPostDisplayImageTableViewCell()
@property (strong, nonatomic) UIImageView *postImageView;
@end

@implementation ViewPostDisplayImageTableViewCell

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
- (void) setPostImage:(UIImage *) image{
    _postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 300)];
    [_postImageView setImage:image];
    [self.contentView addSubview:_postImageView];
}

@end
