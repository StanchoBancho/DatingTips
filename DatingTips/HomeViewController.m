//
//  HomeViewController.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "BuyTipCell.h"
#import "TipCell.h"

#define kCellCount 2

@interface HomeViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, BannerViewContainer>

@property(nonatomic, assign) ADBannerView* bannerView;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property(nonatomic, strong) IBOutlet UIImageView* backgroundView;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@end

@implementation HomeViewController

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.navigationController.navigationBar setHidden:YES];
    
    //setup background
    UIImage* background = nil;
    BOOL isIphone5 = [(AppDelegate*)[[UIApplication sharedApplication] delegate] isIphone5];
    if (isIphone5) {
        background = [UIImage imageNamed:@"Default"];
    }
    else{
        background = [UIImage imageNamed:@"Default-568h"];
    }
    [self.backgroundView setImage:background];
    
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

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated? 0.5f : 0.0f;
    CGRect contentFrame = self.view.bounds;
    CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeigh = 0.0f;
    
    if(self.bannerView != nil){
        self.bannerView.currentContentSizeIdentifier = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifierPortrait;
        bannerHeigh = self.bannerView.bounds.size.height;
        
        if(self.bannerView.bannerLoaded){
            contentFrame.size.height -= bannerHeigh;
            bannerOrigin.y -=bannerHeigh;
        }
        else{
            bannerOrigin.y += bannerHeigh;
        }
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.tableView beginUpdates];
        self.tableView.frame = contentFrame;
        [self.tableView layoutIfNeeded];
        self.bannerView.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, self.bannerView.frame.size.width, bannerHeigh);
        [self.tableView endUpdates];
    }];
}

#pragma mark - Action Methods

-(IBAction)getAnotherButtonPressed:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"In app purchase" message:@"Are you sure you want to buy another tip for $0.99" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

#pragma mark - Banner View Container

-(void)showBannerView:(ADBannerView*)bannerView
{
    self.bannerView = bannerView;
    [self.view addSubview:self.bannerView];
    [self layoutForCurrentOrientation:YES];
}
-(void)hideBannerView:(ADBannerView*)bannerView
{
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
    [self layoutForCurrentOrientation:YES];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.dataSource count] == 1){
        return [self.dataSource count] + 1;
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    if(indexPath.row ==  [self.dataSource count] && [self shouldShowGetAnotherTipForToDay]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"BuyTipCell"];
        [[(BuyTipCell*)cell getAnotherButton] addTarget:self action:@selector(getAnotherButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"TipCell"];
    
    NSString* title = [self.dataSource objectAtIndex:[indexPath row]];
    [(TipCell*)cell  setupCellWithTip:title];
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row ==  [self.dataSource count] && [self shouldShowGetAnotherTipForToDay]){
        return 60.0f;
    }
    CGFloat result = [TipCell cellHeightForTip:self.dataSource[indexPath.row]];
    return result;
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        //set that we buy a tip for today
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* todayInString = [self.dateFormatter stringFromDate:[NSDate date]];
        [defaults setBool:YES forKey:todayInString];
        [self.tableView reloadData];
    }
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
