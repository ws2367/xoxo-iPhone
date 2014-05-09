//
//  NSNumber+MSNumber.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 5/8/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "NSNumber+MSNumber.h"

@implementation NSNumber (MSNumber)

- (NSNumber *)increment
{
    return [NSNumber numberWithInt:([self intValue] + 1)];
}

- (NSNumber *)decrement
{
    return [NSNumber numberWithInt:([self intValue] - 1)];
}
@end
