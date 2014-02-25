//
//  InitializedNSManagedObject.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface InitializedNSManagedObject : NSManagedObject

@property (nonatomic, retain) NSDate *creationDate;

@end
