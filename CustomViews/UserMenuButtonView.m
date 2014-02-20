//
//  UserMenuButtonView.m
//  Cells
//
//  Created by WYY on 2013/11/10.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "UserMenuButtonView.h"

@implementation UserMenuButtonView

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
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [[UIColor colorWithWhite:1 alpha:1] setFill];
    [circle fill];
    
}

@end
