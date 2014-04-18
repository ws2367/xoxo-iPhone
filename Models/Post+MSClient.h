//
//  Post+MSClient.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Post.h"

@interface Post (MSClient)

- (bool) uploadImageToS3;

- (void)sendFollowRequestWithFailureBlock:(void (^)(void))failureBlock;
- (void)sendReportRequestWithFailureBlock:(void (^)(void))failureBlock;

- (void)incrementCommentsCount;

@end
