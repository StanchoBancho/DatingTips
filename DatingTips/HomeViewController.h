//
//  HomeViewController.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableController.h"

@interface HomeViewController : CoreDataTableController

@property (nonatomic, strong) NSArray* inAppPurchaseProducts;
@property (nonatomic, strong) UIManagedDocument* document;

@end
