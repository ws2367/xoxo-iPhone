//
//  BottomBorderTextField.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/19/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "BottomBorderTextField.h"

@implementation BottomBorderTextField

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
 
 CALayer *bottomBorder = [CALayer layer];
 bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
 bottomBorder.frame = CGRectMake(0, self.frame.size.height - 1,
                                 self.frame.size.width, 1);
 [self.layer addSublayer:bottomBorder];
 
}

@end
