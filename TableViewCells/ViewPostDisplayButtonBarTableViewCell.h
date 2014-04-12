//
//  ViewPostDisplayButtonBarCell.h
//  Cells
//
//  Created by Iru on 4/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewPostDisplayButtonBarTableViewCellDelegate;

@interface ViewPostDisplayButtonBarTableViewCell : UITableViewCell
@property (nonatomic, weak) id<ViewPostDisplayButtonBarTableViewCellDelegate> delegate;
-(void) addCommentAndFollowNumbersWithCommentsCount:(NSNumber *)commentNum FollowersCount:(NSNumber *)followNum;

@end


@protocol ViewPostDisplayButtonBarTableViewCellDelegate <NSObject>

@required

- (void) sharePost:(id)sender;
- (void) reportPost:(id)sender;
- (void) followPost:(id)sender;
- (void) commentPost:(id)sender;

@end
