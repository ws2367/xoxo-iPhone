//
//  SuperImageView.m
//  Cells
//
//  Created by Iru on 3/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "SuperImageView.h"

@interface SuperImageView()
@property(strong,nonatomic)NSMutableArray *photosImageViews;
@property(nonatomic)unsigned int atPhotoIndex;
@property(nonatomic)CGPoint startPoint;
@property(weak,nonatomic)UIImageView *currentImageView;

@end

@implementation SuperImageView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _startPoint = [touch locationInView:self];
    NSLog(@"touched!");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
    CGFloat touchX =[touch locationInView:self].x;
    CGFloat xoffset =touchX - _startPoint.x;
    [_currentImageView setFrame:CGRectMake(xoffset, 0, self.frame.size.width, self.frame.size.height)];
    if(touchX > _startPoint.x){
        if(_atPhotoIndex > 0){
            NSLog(@"in here");
            UIImageView *leftImageView = [_photosImageViews objectAtIndex:_atPhotoIndex -1];
            [leftImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//            [leftImageView setFrame:CGRectMake(-self.frame.size.width + xoffset, 0, self.frame.size.width, self.frame.size.height)];
            [self addSubview:leftImageView];
        }
    }
    else{
        if(_atPhotoIndex < [_photosImageViews count] - 1){
            UIImageView *rightImageView = [_photosImageViews objectAtIndex:_atPhotoIndex +1];
            [rightImageView setFrame:CGRectMake(self.frame.size.width - xoffset, 0, self.frame.size.width, self.frame.size.height)];
            [self addSubview:rightImageView];
        }
    }
    NSLog(@"touchmoved!");
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
	[_currentImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_currentImageView];
	NSLog(@"touchended");
}

- (void)addPhoto:(UIImage *)newImage{
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [newImageView setImage:newImage];
    [_photosImageViews addObject:newImageView];
    _atPhotoIndex = [_photosImageViews count] - 1;
    _currentImageView = newImageView;
    [self addSubview:newImageView];
    NSLog(@"added photo");
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
