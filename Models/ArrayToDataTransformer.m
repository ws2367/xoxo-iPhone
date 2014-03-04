//
//  ArrayToDataTransformer.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ArrayToDataTransformer.h"


// refer to http://www.lextech.com/2013/01/core-data-transformable-attributes/

@implementation ArrayToDataTransformer

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
