//
//  HistoryViewController.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/9/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableController.h"

@interface HistoryViewController : CoreDataTableController

@property (nonatomic, strong) UIManagedDocument* document;

@end
