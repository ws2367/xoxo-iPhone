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
@property(nonatomic)int atPhotoIndex;
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
            UIImageView *leftImageView = [_photosImageViews objectAtIndex:_atPhotoIndex -1];
            [leftImageView setFrame:CGRectMake(-self.frame.size.width + xoffset, 0, self.frame.size.width, self.frame.size.height)];
            [leftImageView setHidden:NO];
        }
    }
    else{
        if(_atPhotoIndex < [_photosImageViews count] - 1){
            NSLog(@"moving left....");
            UIImageView *rightImageView = [_photosImageViews objectAtIndex:_atPhotoIndex +1];
            [rightImageView setFrame:CGRectMake(self.frame.size.width + xoffset, 0, self.frame.size.width, self.frame.size.height)];

//            [rightImageView setFrame:CGRectMake(self.frame.size.width - xoffset, 0, self.frame.size.width, self.frame.size.height)];
            [rightImageView setHidden:NO];
        }
    }
    NSLog(@"touchmoved!");
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGFloat touchX =[touch locationInView:self].x;
    if(_startPoint.x - touchX < -self.frame.size.width/3 && _atPhotoIndex > 0){
        NSLog(@"we want to see left");
        UIImageView *leftImageView = [_photosImageViews objectAtIndex:_atPhotoIndex - 1];
        [self animationToCenter:leftImageView pushaway:_currentImageView right:YES];
        _atPhotoIndex = _atPhotoIndex -1;
        _currentImageView = leftImageView;
    }
    else if(_startPoint.x - touchX > self.frame.size.width/3 && _atPhotoIndex < [_photosImageViews count] - 1){
        NSLog(@"we want to see right");
        NSLog(@"[_photosImageViews count] %d", (int)[_photosImageViews count]);
        UIImageView *rightImageView = [_photosImageViews objectAtIndex:_atPhotoIndex + 1];
        [self animationToCenter:rightImageView pushaway:_currentImageView right:NO];
        _atPhotoIndex = _atPhotoIndex + 1;
        _currentImageView = rightImageView;
    }
    else{
        if(_startPoint.x - touchX > 0 ){
            if(_atPhotoIndex < [_photosImageViews count] - 1){
                UIImageView *rightImageView = [_photosImageViews objectAtIndex:_atPhotoIndex + 1];
                [self animationToCenter:_currentImageView pushaway:rightImageView right:YES];
            }
            else{
                [self animationToCenter:_currentImageView pushaway:nil right:NO];
            }
        }
        else{
            if(_atPhotoIndex > 0){
                UIImageView *leftImageView = [_photosImageViews objectAtIndex:_atPhotoIndex - 1];
                [self animationToCenter:_currentImageView pushaway:leftImageView right:NO];
            }
            else{
                [self animationToCenter:_currentImageView pushaway:nil right:NO];
            }

        }
        
    }
    [_currentImageView setHidden:NO];
}

-(void)animationToCenter:(UIImageView *)toCenterImageView pushaway:(UIImageView *)toPushImageView right:(BOOL)toright{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         toCenterImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
                         if(toPushImageView != nil){
                             if(toright){
                                 toPushImageView.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
                             }
                             else{
                                 toPushImageView.frame = CGRectMake(-self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
                             }
                         }
                     }
                     completion:^(BOOL finished){
                     }];

}

- (void)addPhoto:(UIImage *)newImage{
    if(_photosImageViews == nil){
        _photosImageViews = [[NSMutableArray alloc] init];
    }
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v setHidden:YES];
    }
    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    newImageView.contentMode = UIViewContentModeScaleAspectFit;
    [newImageView setImage:newImage];
    [_photosImageViews addObject:newImageView];
    _atPhotoIndex = [_photosImageViews count] - 1;
    _currentImageView = newImageView;
    [self addSubview:newImageView];
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
