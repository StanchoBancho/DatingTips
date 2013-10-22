//
//  HomeViewController.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "HomeViewController.h"
#import "BuyTipCell.h"
#import "TipCell.h"
#import "LoadingViewController.h"
#import <StoreKit/StoreKit.h>
#import "IAPManager.h"
#import "Tip.h"

@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, assign) NSInteger numberOfTips;
@end

@implementation HomeViewController

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.navigationController.navigationBar setHidden:YES];
    
    UINib* tipCellNib = [UINib nibWithNibName:@"TipCell" bundle:nil];
    [self.tableView registerNib:tipCellNib forCellReuseIdentifier:@"TipCell"];
    
    UINib* buyTipCellNib = [UINib nibWithNibName:@"BuyTipCell" bundle:nil];
    [self.tableView registerNib:buyTipCellNib forCellReuseIdentifier:@"BuyTipCell"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tip"];
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"tipId" ascending:YES];
    request.sortDescriptors = @[ sortDescriptor1];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void)setInAppPurchaseProducts:(NSArray *)inAppPurchaseProducts
{
    if(inAppPurchaseProducts){
        _inAppPurchaseProducts = inAppPurchaseProducts;
    }
    else{
        _inAppPurchaseProducts = @[];
    }
    [self.tableView reloadData];
}

- (void)setDocument:(UIManagedDocument *)document;
{
    if (_document != document) {
        _document = document;
        [self setupFetchedResultsController];
    }
}

#pragma mark - Action Methods

-(IBAction)getAnotherButtonPressed:(id)sender
{
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
    self.numberOfTips = [super tableView:self.tableView numberOfRowsInSection:section];
    NSInteger result = self.numberOfTips + [self.inAppPurchaseProducts count];
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    if(indexPath.row >= self.numberOfTips){
        NSInteger indexInProducts = [indexPath row] - self.numberOfTips;
        cell = [tableView dequeueReusableCellWithIdentifier:@"BuyTipCell"];
        [[(BuyTipCell*)cell getAnotherButton] addTarget:self action:@selector(getAnotherButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        SKProduct* selectedProduct = self.inAppPurchaseProducts[indexInProducts];
        NSString* buttonTitle = [NSString stringWithFormat:@"%@ - %.2f",selectedProduct.localizedTitle, selectedProduct.price.floatValue];
        
        [[(BuyTipCell*)cell getAnotherButton] setTitle:buttonTitle forState:UIControlStateNormal];
        [[(BuyTipCell*)cell getAnotherButton] setTitle:buttonTitle forState:UIControlStateHighlighted];

        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"TipCell"];
    Tip* currentTip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString* title = currentTip.tipDescription;
    [(TipCell*)cell setupCellWithTip:title];
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= self.numberOfTips){
        return 70.0f;
    }
    Tip* currentTip = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CGFloat result = [TipCell cellHeightForTip:currentTip.tipDescription];
    return result;
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if(buttonIndex == 1){
//        //set that we buy a tip for today
//        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//        NSString* todayInString = [self.dateFormatter stringFromDate:[NSDate date]];
//        [defaults setBool:YES forKey:todayInString];
//        [self.tableView reloadData];
//    }
}

#pragma mark - Utility

-(BOOL)shouldShowGetAnotherTipForToDay
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* todayInString = [self.dateFormatter stringFromDate:[NSDate date]];
    BOOL result = ![defaults boolForKey:todayInString];
    return result;
}

@end
