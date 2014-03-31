//
//  RestKitInitializer.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/31/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestKitInitializer : NSObject

+ (void) setupWithObjectManager:(RKObjectManager *)objectManager inManagedObjectStore:(RKManagedObjectStore *)managedObjectStore;

@end
