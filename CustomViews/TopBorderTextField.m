//
//  TopBorderTextField.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/21/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "TopBorderTextField.h"

@implementation TopBorderTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    topBorder.frame = CGRectMake(0, 0,
                                    self.frame.size.width, 1);
    [self.layer addSublayer:topBorder];
    
}


@end
