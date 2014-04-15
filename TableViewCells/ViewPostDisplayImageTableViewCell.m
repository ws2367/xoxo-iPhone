//
//  ViewPostViewImageTableViewCell.m
//  Cells
//
//  Created by Iru on 4/3/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayImageTableViewCell.h"
#import "UIColor+MSColor.h"

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
    [self.contentView setBackgroundColor:[UIColor colorForYoursWhite]];
    if(image.size.height > VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT){
        _postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width*VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT/image.size.height, VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT)];
        [_postImageView setCenter:CGPointMake(WIDTH/2, VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT/2)];
    } else{
        _postImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [_postImageView setCenter:CGPointMake(WIDTH/2, image.size.height/2)];
        
    }
    [_postImageView setImage:image];
    [self.contentView addSubview:_postImageView];
}

@end
