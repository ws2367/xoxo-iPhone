//
//  BIDCellView.m
//  Cells
//
//  Created by WYY on 13/10/3.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BIDCellView.h"

@implementation BIDCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(7, 10, 306, 90) cornerRadius:7.0f];
    [[UIColor colorWithWhite:1 alpha:1] setFill];
    [roundedRect fill];
    UIBezierPath *highlight = [UIBezierPath bezierPathWithRect:CGRectMake(13, 78, 295, 18)];
    [[UIColor colorWithRed:0 green:0.4 blue:0.8 alpha:0.1] setFill];
    [highlight fill];
}


@end
