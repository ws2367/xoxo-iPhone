//
//  ViewPostDisplayCommentTableViewCell.h
//  Cells
//
//  Created by Iru on 4/3/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

@interface ViewPostDisplayCommentTableViewCell : UITableViewCell


-(void) setComment:(Comment *)comment withIcon:(NSString *)fileString;
@end
