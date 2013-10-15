//
//  CommunicationManager.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommunicationManager : NSObject

+ (CommunicationManager*)sharedProvider;

@property (nonatomic, strong) UIManagedDocument *document;

- (void)getDailyTips:(void(^)(NSArray* tips, NSError* error))completion;
- (void)getPayedTipsIdentifiers:(void(^)(NSArray* tipsIds, NSError* error))completion;

@end
