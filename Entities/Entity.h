//
//  Entity.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *taggedIn;
@end

@interface Entity (CoreDataGeneratedAccessors)

- (void)addTaggedInObject:(Post *)value;
- (void)removeTaggedInObject:(Post *)value;
- (void)addTaggedIn:(NSSet *)values;
- (void)removeTaggedIn:(NSSet *)values;

@end
