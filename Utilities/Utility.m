//
//  Utility.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/20/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Utility.h"

@implementation Utility

// in case you don't know, class methods are prefixed by plus sign (+)
+ (BOOL) compareUIColorBetween:(UIColor *)colorA and:(UIColor *)colorB
{
    CGFloat redA, redB, greenA, greenB, blueA, blueB, alphaA, alphaB;
    [colorA getRed:&redA green:&greenA blue:&blueA alpha:&alphaA];
    [colorB getRed:&redB green:&greenB blue:&blueB alpha:&alphaB];
    
    if (redA == redB && greenA == greenB && blueA == blueB && alphaA == alphaB)
        return FALSE;
    else
        return TRUE;
}

@end
