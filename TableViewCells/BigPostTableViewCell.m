//
//  BigPostTableViewCell.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BigPostTableViewCell.h"
#import <QuartzCore/QuartzCore.h> //for gradient color
#import "UIColor+MSColor.h"

#define BUTTON_ORIGIN_Y 205
#define POST_IMAGE_HEIGHT 196

@interface BigPostTableViewCell()

@property (strong,nonatomic)  UIImageView *mooseView;

@property (strong,nonatomic)  UIView *blackMask;
@property (nonatomic) bool gradientFlag;

@property (strong, nonatomic) UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *entityButton;

@property (strong, nonatomic)UIImageView *postImageView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (copy, nonatomic) NSString *dateToShow;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UIButton *reportButton;
@property (strong, nonatomic) UIButton *whatButton;


@property (strong,nonatomic) UILabel *commentLabel;
@property (strong,nonatomic) UILabel *followLabel;
@property (strong, nonatomic) NSAttributedString *commentString;
@property (strong, nonatomic) NSAttributedString *followString;
@property (nonatomic) CGFloat imageWidth;

@property (strong, nonatomic) CAGradientLayer *blackLayer;
@property (strong, nonatomic) CAGradientLayer *gradientLeft;




/*
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *hateButton;
@property (strong, nonatomic) IBOutlet UILabel *likeValue;
@property (strong, nonatomic) IBOutlet UILabel *hateValue;
 */
// TODO: what it this lowerMask for??
//@property (weak, nonatomic) IBOutlet UIView *lowerMask;


@end

@implementation BigPostTableViewCell{
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //[_lowerMask setAlpha:0.8];
        //_lowerMask.opaque = FALSE;
        //_gradientFlag = FALSE;
        //[self createGradient];
        [self.contentView setBackgroundColor:[UIColor colorForBackground]];
        [self addLowerButtons];
    }
    return self;
}

/*
-(void) updateConstraints{
    [super updateConstraints];
    //apply our background color for cells
    [self.contentView setBackgroundColor:[UIColor colorForBackground]];
    [self addLowerButtons];
}*/




- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// set content of posts as well as other attributes which are hard-coded
// This is a setter that is wired with the variable content by objective-C automatically
- (void)setContent:(NSString *)n
{
    if (![n isEqualToString:_content]) {
        //TODO: check if this copying actually works as we want
        _content = [n copy];
        //NSRange stringRange = {0,65};
        //if(_content.length > 65){
        //    _content = [_content substringWithRange:stringRange];
        //    _content = [_content stringByAppendingFormat:@"..."];
        //}
        _contentTextView.text = _content;
    }
    
    /*
     _likeNum = 4;
    _hateNum = 3;
    _likeValue.text = [NSString stringWithFormat:@"%d", (int)_likeNum];
    _hateValue.text = [NSString stringWithFormat:@"%d", (int)_hateNum];
    
    _liked = false;
    _hated = false;
    [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
    [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];
     */

}

// This is a setter that is wired with the variable entities by objective-C automatically
// TODO: copy objects to _entities then show _entities on the view instead of outter pointers
// Like what we do in setContent
-(void) setEntities:(NSArray *)entities{
    
    if ([entities count] > 0) {
        // TOOD: change it to show multiple names
        [_entityButton setTitle:[entities objectAtIndex:0][@"name"] forState:UIControlStateNormal];

        /*for(NSDictionary *item in JSONArr) {
        [self.posts addObject:item];
         }*/
        //NSDictionary
        //NSArray *keys = [entities allValues];
        //  NSLog(@"%@",keys);
        //NSArray *eachEntity = [entities allValues];
        //NSLog(@"%@", [eachEntity objectAtIndex:0]);
    }
}


-(void) setDateToShow:(NSString *)dateToShow{
    _dateToShow = [dateToShow copy];
    _dateLabel.text = _dateToShow;
}



#pragma mark -
#pragma mark Button Methods
// TODO: we gonna use exclamation mark instead of like or hate
/*
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
 */

-(void) setCellWithImage:(UIImage *)photo Entities:(NSArray *)entities Content:(NSString *)content CommentsCount:(NSNumber *)commentsCount FollowersCount:(NSNumber *)followersCount atDate:(NSDate *)date hasFollowed:(BOOL)hasFollowed{
    //first process photo
    if(!_postImageView){
        _postImageView = [[UIImageView alloc] init];
    }
    
    if(!photo){
        [self addLaunchingImage];
        [_followLabel removeFromSuperview];
        [_commentLabel removeFromSuperview];
        return;
    }

    _imageWidth = photo.size.width*POST_IMAGE_HEIGHT/photo.size.height;
    [_postImageView setFrame:CGRectMake(WIDTH - _imageWidth, 0, _imageWidth, POST_IMAGE_HEIGHT)];
    
    [_postImageView setImage:photo];
    [self.contentView addSubview:_postImageView];
    [self createGradient];
    //then process entities
    [self generateNameLabels:entities];
    //then content
    [self generateContentLabel:content];
    
    
    //then display date
    [self displayDate:date];
    
    //add mask to let user to click into post
    [self addClickAreaToViewPost];
    
    [self addCommentAndFollowNumbersWithCommentsCount:[commentsCount integerValue] FollowersCount:[followersCount integerValue]];
    
    //change follow icon
    if(hasFollowed){
        [_whatButton setImage:[UIImage imageNamed:@"icon-followII.png"] forState:UIControlStateNormal];
    } else{
        [_whatButton setImage:[UIImage imageNamed:@"icon-follow.png"] forState:UIControlStateNormal];
    }
    
    
}

-(void) addClickAreaToViewPost{
    UIButton *clickArea = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, POST_IMAGE_HEIGHT)];
    [self.contentView addSubview:clickArea];
    [clickArea addTarget:self action:@selector(viewPostClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) viewPostClicked:(id)sender{
    MSDebug(@"view post clicked!");
    if(_delegate && [_delegate respondsToSelector:@selector(CellPerformViewPost:)]){
        [_delegate CellPerformViewPost: sender];
        MSDebug(@"called delegate");
    }
}

-(void) addLaunchingImage{
    UIView *logoArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, POST_IMAGE_HEIGHT)];
    [logoArea setBackgroundColor:[UIColor colorForYoursOrange]];
    [self.contentView addSubview:logoArea];
    UIImage *logoImage = [UIImage imageNamed:@"logo_white.png"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
    [logoView setFrame:CGRectMake(80, 60, logoImage.size.width/2, logoImage.size.height/2)];
    [self.contentView addSubview:logoView];
}

#pragma mark -
#pragma mark Swipe Methods
- (void) swipeLeft{
    
}
- (void) swipeRight{
    _mooseView = [[UIImageView alloc] init];
    _mooseView.frame = CGRectMake(-WIDTH + 135, 70, 50, 50);
    [_mooseView setImage:[UIImage imageNamed:@"moose"]];
    _mooseView.opaque = false;
    _mooseView.alpha = 1;
    
    _blackMask = [[UIView alloc] init];
    _blackMask.frame = CGRectMake(0 , 0, self.frame.size.width, self.frame.size.height);
    _blackMask.opaque = FALSE;
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0;
    [self addSubview:_blackMask];
    [self addSubview:_mooseView];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _mooseView.frame = CGRectMake(135, 70, 50, 50);
                         _blackMask.alpha = 0.8;

                     }
                     completion:^(BOOL finished){
                         [self endMooseAnimation];
                         
                     }];
    
}

-(void) endMooseAnimation{
    [UIView animateWithDuration:ANIMATION_DURATION*2.5
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _mooseView.alpha = 0;
                         _blackMask.alpha = 0;
                         
                     }
                     completion:^(BOOL finished){
                         [_mooseView removeFromSuperview];
                         [_blackMask removeFromSuperview];
                         
                     }];
}

#pragma mark -
#pragma mark Button Methods
-(void) shareButtonPressed:(id)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(sharePost:)]){
        [_delegate sharePost:sender];
    }
}
-(void) commentButtonPressed:(id)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(commentPost:)]){
        [_delegate commentPost:sender];
    }
}
-(void) followButtonPressed:(id)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(followPost:)]){
        [_delegate followPost:sender];
    }
}
-(void) reportButtonPressed:(id)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(reportPost:)]){
        [_delegate reportPost:sender];
    }
}




#pragma mark -
#pragma mark UI Helper Methods

-(void)displayDate:(NSDate *)date{
    UIImage *timeIcon =[UIImage imageNamed:@"icon-time.png"];
    UIImageView *timeIconView = [[UIImageView alloc] initWithImage:timeIcon];
    [timeIconView setFrame:CGRectMake(275, 8, timeIcon.size.width, timeIcon.size.height)];
    [self.contentView addSubview:timeIconView];
    NSAttributedString *dateString = [[NSAttributedString alloc] initWithString:[Utility getDateToShow:date inWhole:NO] attributes:[Utility getMultiPostsDateFontDictionary]];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, -10, 50, 50)];
    [dateLabel setAttributedText:dateString];
    [dateLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.3]];
    [dateLabel setShadowOffset:CGSizeMake(0.5,0.5)];
    [self.contentView addSubview:dateLabel];
}
-(void)generateContentLabel:(NSString *)content{
    NSString *toDisplay;
    if([content length] > 50){
        toDisplay = [[content substringWithRange:NSMakeRange(0, 50)] stringByAppendingString:@"..."];
    } else{
        toDisplay = content;
    }
    NSAttributedString *contentText = [[NSAttributedString alloc]
                                       initWithString:toDisplay attributes:[Utility getMultiPostsContentFontDictionary]];
    _contentTextView =[[UITextView alloc] initWithFrame:CGRectMake(8, 118, WIDTH/2+ 20, 78)];
    [_contentTextView setAttributedText:contentText];
    [_contentTextView setBackgroundColor:[UIColor clearColor]];
    [_contentTextView setEditable:NO];
    [_contentTextView setSelectable:NO];
    [_contentTextView setScrollEnabled:NO];
    [self.contentView addSubview:_contentTextView];
}

-(void)generateNameLabels:(NSArray *)entities{
    if([entities count] >= 1){
         NSDictionary *firstEntity = [entities firstObject];
        if([entities count] > 2){
            NSString *namePlusDot = [firstEntity[@"name"] stringByAppendingString:@"..."];
            [self generateNameLabel:namePlusDot  atX:8 Y:85];
        } else{
            [self generateNameLabel:firstEntity[@"name"]  atX:8 Y:85];
        }
    }
    if([entities count] >= 2){
         NSDictionary *secondEntity = [entities objectAtIndex:1];
        [self generateNameLabel:secondEntity[@"name"]  atX:8 Y:52];
    }
}

-(void) generateNameLabel:(NSString *)name atX:(CGFloat)originX Y:(CGFloat)originY{
    UIImage *nameIconImage =[UIImage imageNamed:@"icon-name.png"];
    UIImageView *nameIconImageView = [[UIImageView alloc] initWithImage:nameIconImage];
    [nameIconImageView setFrame:CGRectMake(originX, originY +8, nameIconImage.size.width, nameIconImage.size.height)];
    [self.contentView addSubview:nameIconImageView];
    NSAttributedString *nameString = [[NSAttributedString alloc] initWithString:name attributes:[Utility getMultiPostsNameFontDictionary]];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX + 28, originY, WIDTH/2 + 50, 50)];
    [nameLabel setAttributedText:nameString];
    [self.contentView addSubview:nameLabel];
}

-(void) addCommentAndFollowNumbersWithCommentsCount:(NSInteger)commentNum FollowersCount:(NSInteger)followNum{
    [_commentLabel removeFromSuperview];
    [_followLabel removeFromSuperview];
    _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(102, BUTTON_ORIGIN_Y+3, 50, 18)];
    _followLabel = [[UILabel alloc] initWithFrame:CGRectMake(184, BUTTON_ORIGIN_Y+3, 50, 18)];
    _commentString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)commentNum] attributes:[Utility getCommentNumberFontDictionary]];
    _followString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)followNum] attributes:[Utility getFollowNumberFontDictionary]];
    [_commentLabel setAttributedText:_commentString];
    [_followLabel setAttributedText:_followString];
    [self.contentView addSubview:_commentLabel];
    [self.contentView addSubview:_followLabel];
}

- (void)addLowerButtons{
    [self createVerticalLineAtOriginX:98 andY:BUTTON_ORIGIN_Y+3 withColor:[UIColor colorForYoursBlue]];
    [self createVerticalLineAtOriginX:180 andY:BUTTON_ORIGIN_Y+3 withColor:[UIColor colorForYoursOrange]];
    _shareButton = [self createLowerButtonAtOriginX:15 andY:BUTTON_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-newshare.png"]];
    _commentButton = [self createLowerButtonAtOriginX:64 andY:BUTTON_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-newcomment.png"]];
    _whatButton = [self createLowerButtonAtOriginX:150 andY:BUTTON_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-follow.png"]];
    _reportButton = [self createLowerButtonAtOriginX:285 andY:BUTTON_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-newreport.png"]];
    [_shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_whatButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_reportButton addTarget:self action:@selector(reportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(UIButton *)createLowerButtonAtOriginX:(int)originX andY:(int)originY withImage:(UIImage *)buttonImage{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(originX-4, originY-4, buttonImage.size.width + 8, buttonImage.size.height + 8);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [self.contentView addSubview:button];
    return button;
}

-(void) createVerticalLineAtOriginX:(int)originX andY:(int)originY withColor:(UIColor *)lineColor{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, 1, 18)];
    lineView.backgroundColor = lineColor;
    [self.contentView addSubview:lineView];
}

// This is where we make the gradient mask on pictures
-(void) createGradient{
    // Flag tells whether it is a new start or a refreshing
    
    //remove it and then add them back
    [_blackLayer removeFromSuperlayer];
    [_gradientLeft removeFromSuperlayer];
    
    
    _blackLayer = [CAGradientLayer layer];
    _gradientLeft = [CAGradientLayer layer];
    if(_imageWidth > (3*WIDTH)/4){
        [_blackLayer setFrame:CGRectMake(0 , 0, WIDTH/4, POST_IMAGE_HEIGHT)];
        [_gradientLeft setFrame:CGRectMake(WIDTH/4,0 , WIDTH/3, POST_IMAGE_HEIGHT)];
    } else{
        [_blackLayer setFrame:CGRectMake(0 , 0, WIDTH - _imageWidth, POST_IMAGE_HEIGHT)];
        [_gradientLeft setFrame:CGRectMake(WIDTH - _imageWidth, 0 ,  _imageWidth/3, POST_IMAGE_HEIGHT)];
    }
        
    _blackLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:1] CGColor],(id)[[UIColor colorWithWhite:0 alpha:1] CGColor], nil];
    _gradientLeft.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0] CGColor],(id)[[UIColor colorWithWhite:0 alpha:1] CGColor], nil];
    _gradientLeft.endPoint = CGPointMake(0, 0.5);
    _gradientLeft.startPoint = CGPointMake(1, 0.5);

    [self.contentView.layer addSublayer:_blackLayer];
    [self.contentView.layer addSublayer:_gradientLeft];
}



@end
