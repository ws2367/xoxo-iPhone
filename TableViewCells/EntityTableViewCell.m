//
//  EntityCell.m
//  Cells
//
//  Created by WYY on 13/10/17.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "EntityTableViewCell.h"
#import "CircleView.h"

@interface EntityTableViewCell ()

@property (weak, nonatomic) IBOutlet CircleView *circleView;

@end

@implementation EntityTableViewCell

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


- (void)setPic:(NSString *)c
{
    if (![c isEqualToString:_pic]) {
        _pic = [c copy];
        _circleView.image = [UIImage imageNamed:_pic];
    }
}


- (void)setName:(NSString *)c
{
    if (![c isEqualToString:_name]) {
        _name = [c copy];
        _nameLabel.text = _name;
    }
}

- (void)setLocation:(NSString *)c
{
    if (![c isEqualToString:_location]) {
        _location = [c copy];
        _locationLabel.text = _location;
    }
}
- (void)setInstitution:(NSString *)c
{
    if (![c isEqualToString:_institution]) {
        _institution = [c copy];
        _institutionLabel.text = _institution;
    }
}

@end
