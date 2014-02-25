//
//  ImageToDataTransformer.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ImageToDataTransformer.h"

@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}


+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	return UIImagePNGRepresentation(value);
}


- (id)reverseTransformedValue:(id)value {
	return [[UIImage alloc] initWithData:value];
}

@end

