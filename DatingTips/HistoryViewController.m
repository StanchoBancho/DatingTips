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

@interface HistoryViewController ()
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* dataSource;

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
    UINib* tipCellNib = [UINib nibWithNibName:@"TipCell" bundle:nil];
    [self.tableView registerNib:tipCellNib forCellReuseIdentifier:@"TipCell"];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults* standardDefaults = [NSUserDefaults standardUserDefaults];
    NSArray* currentTips = [standardDefaults objectForKey:@"all_tips"];
    if(currentTips){
        self.dataSource = currentTips;
    }
    else{
        self.dataSource = @[];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"TipCell"];
    NSString* title = [self.dataSource objectAtIndex:[indexPath row]];
    [(TipCell*)cell setupCellWithTip:title];
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result = [TipCell cellHeightForTip:self.dataSource[indexPath.row]];
    return result;
}

@end
