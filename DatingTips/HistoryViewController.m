//
//  HistoryViewController.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/9/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "HistoryViewController.h"
#import "LoadingViewController.h"
#import "TipCell.h"
#import "Tip.h"

@interface HistoryViewController ()

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
 
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    [self.dateFormatter setDateFormat:@"yyyy MM dd"];
    
    UINib* tipCellNib = [UINib nibWithNibName:@"TipCell" bundle:nil];
    [self.tableView registerNib:tipCellNib forCellReuseIdentifier:@"TipCell"];
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tip"];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    
    request.sortDescriptors = @[ sortDescriptor1];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (void)setDocument:(UIManagedDocument *)document;
{
    if (_document != document) {
        _document = document;
        [self setupFetchedResultsController];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonPressed:(id)sender
{
    LoadingViewController* loadingVc = (LoadingViewController*)[self.navigationController.viewControllers firstObject];
    [loadingVc setShouldDownloadAgainTipOfTheDay:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"TipCell"];

    Tip* currentTip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString* title = currentTip.tipDescription;
    [(TipCell*)cell setupCellWithTip:title];
    NSString* dateString = [self.dateFormatter stringFromDate:currentTip.date];
    [[(TipCell*)cell dayLabel] setText:dateString];

    [(TipCell*)cell setupCellWithTip:title];
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tip* currentTip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat result = [TipCell cellHeightForTip:currentTip.tipDescription];
    return result;
}

@end
