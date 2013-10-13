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

@interface LoadingViewController ()

@property(nonatomic, strong) IBOutlet UIButton* showMeATipButton;
@property (strong, nonatomic) IBOutlet UIButton *historyButton;
@property(nonatomic, strong) NSArray* tips;
@property(nonatomic, strong) NSArray* inAppPurchaseProducts;

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
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.shouldDownloadAgainTipOfTheDay){
        [self downloadFreeTipsAndPaidTipsIds];
    }
    self.shouldDownloadAgainTipOfTheDay = YES;
}

-(void)downloadFreeTipsAndPaidTipsIds
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
    
    //download daylitips
    [[CommunicationManager sharedProvider] getDailyTips:^(NSArray *tips, NSError *error) {
        if (tips) {
            NSMutableArray* newTips = [NSMutableArray arrayWithCapacity:tips.count];
            for (NSString* tip in tips) {
                [newTips addObject:[NSString stringWithFormat:@"          %@",tip]];
            }
            self.tips = newTips;
            
            //do some dummy store for the tips for now
            NSUserDefaults* standardDefaults = [NSUserDefaults standardUserDefaults];
            NSArray* currentTips = [standardDefaults objectForKey:@"all_tips"];
            if(!currentTips){
                [standardDefaults setObject:[self.tips copy] forKey:@"all_tips"];
            }
            else{
                NSMutableArray* newCurrentTips = [NSMutableArray arrayWithArray:currentTips];
                for (NSString* newTip in self.tips) {
                    if(![newCurrentTips containsObject:newTip]){
                        [newCurrentTips addObject:newTip];
                    }
                }
                [standardDefaults setObject:newCurrentTips forKey:@"all_tips"];
            }
            BOOL syncResult = [standardDefaults synchronize];
            NSLog(@"Current tips re synced with STATUS: %d", syncResult);
            
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
      //  self.tips = @[@"       asdsa 234234 ewrafsasf asasdasd asdasdad dwadawc zdsdgs awawdas asgsag  asfasf  asasdsad  dasdaw  wawaegh  asfassdg a asawh  ssss sss twahws ssdas"];
        [(HomeViewController*)segue.destinationViewController setDataSource:self.tips];
        [(HomeViewController*)segue.destinationViewController setInAppPurchaseProducts:self.inAppPurchaseProducts];
    }
}

@end
