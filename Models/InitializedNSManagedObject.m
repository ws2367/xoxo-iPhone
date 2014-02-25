//
//  InitializedNSManagedObject.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "InitializedNSManagedObject.h"

@implementation InitializedNSManagedObject

@dynamic creationDate;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.creationDate = [NSDate date];
}

@end
