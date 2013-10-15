//
//  Tag.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/15/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tip;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * tagTitle;
@property (nonatomic, retain) NSSet *tips;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addTipsObject:(Tip *)value;
- (void)removeTipsObject:(Tip *)value;
- (void)addTips:(NSSet *)values;
- (void)removeTips:(NSSet *)values;

@end
