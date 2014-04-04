//
//  Post+MSS3Client.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Post.h"

@interface Post (MSS3Client)

- (bool) uploadImageToS3;


@end
