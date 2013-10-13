//
//  IAPManager.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/13/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPManager : NSObject

+ (IAPManager *)sharedInstance;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end
