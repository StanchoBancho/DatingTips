//
//  Tip.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/15/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Tip : NSManagedObject

@property (nonatomic, retain) NSString * tipDescription;
@property (nonatomic, retain) NSNumber * tipId;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Tip (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
