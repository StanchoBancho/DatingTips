//
//  ViewController.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "LoadingViewController.h"
#import "CommunicationManager.h"
#import "HomeViewController.h"
#import "IAPManager.h"
#import "CoreDataManager.h"

@interface LoadingViewController ()

@property(nonatomic, strong) IBOutlet UIButton* showMeATipButton;
@property (strong, nonatomic) IBOutlet UIButton *historyButton;
@property(nonatomic, strong) NSArray* tips;
@property(nonatomic, strong) NSArray* inAppPurchaseProducts;
@property(nonatomic, strong) UIManagedDocument* document;

@end

@implementation LoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];

    UIFont* buttonFont = [UIFont fontWithName:@"Fishfingers" size:28];
    [self.showMeATipButton.titleLabel setFont:buttonFont];
    [self.historyButton.titleLabel setFont:buttonFont];
    [self.showMeATipButton setHidden:YES];
    self.shouldDownloadAgainTipOfTheDay = YES;
    
    //setup the uimanaged document
 
    self.navigationController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.shouldDownloadAgainTipOfTheDay){
        [[CoreDataManager sharedManager] setupDocument:^(UIManagedDocument *document, NSError *error) {
            if(!error && document){
                self.document = document;
                [self downloadProductsFromStoreKit];
                [self downloadFreeTips];
            }
        }];
        
    }
    self.shouldDownloadAgainTipOfTheDay = YES;
}

-(void)downloadProductsFromStoreKit
{
    //download in app purchase ids
    [[IAPManager sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            HomeViewController* homeViewController = nil;
            for(UIViewController* vc in self.navigationController.viewControllers){
                if ([vc isKindOfClass:[HomeViewController class]]){
                    homeViewController = (HomeViewController*)vc;
                }
            }
            if(homeViewController){
                [homeViewController setInAppPurchaseProducts:products];
            }
            self.inAppPurchaseProducts = products;
        }
    }];
}

-(void)downloadFreeTips
{
    //download daylitips
    [[CommunicationManager sharedProvider] getDailyTips:^(NSArray *tips, NSError *error) {
        if (tips) {
            [[CoreDataManager sharedManager] updateTipsWithJSONArray:tips];
            [UIView animateWithDuration:0.3 animations:^{
                [self.showMeATipButton setHidden:NO];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowHomeViewControllerSegue"]){
        [(HomeViewController*)segue.destinationViewController setDocument:[[CoreDataManager sharedManager] document]];
        [(HomeViewController*)segue.destinationViewController setInAppPurchaseProducts:self.inAppPurchaseProducts];
    }
}

@end
