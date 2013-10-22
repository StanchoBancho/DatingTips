//
//  CoreDataTableController.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/17/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "CoreDataTableController.h"

@interface CoreDataTableController ()

@end

@implementation CoreDataTableController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != _fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        _fetchedResultsController.delegate = self;
        
        if (_fetchedResultsController) {
            NSError *error;
            [_fetchedResultsController performFetch:&error];
            if (error) {
                NSLog(@"setFetchedResultsController: %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger result = [[self.fetchedResultsController sections] count];
    return result;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger result = [sectionInfo numberOfObjects];
    return result;
}

@end
