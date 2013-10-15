//
//  Tip.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/15/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tip : NSManagedObject

@property (nonatomic, retain) NSNumber * tipId;
@property (nonatomic, retain) NSString * tipDescription;
@property (nonatomic, retain) NSManagedObject *tags;

@end
