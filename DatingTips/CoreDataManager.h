//
//  CoreDataManager.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/12/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

@property (nonatomic, strong) UIManagedDocument *document;
+ (CoreDataManager*)sharedManager;

- (void)setupDocument:(void(^)(UIManagedDocument* document, NSError* error))completion;

- (void)updateTipsWithJSONArray:(NSArray*)tipsArray;


@end
