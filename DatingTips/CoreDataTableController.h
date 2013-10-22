//
//  CoreDataTableController.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/17/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataTableController : UIViewController<NSFetchedResultsControllerDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
