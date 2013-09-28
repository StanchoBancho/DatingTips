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

@interface LoadingViewController ()

@property(nonatomic, strong) IBOutlet UIButton* showMeATipButton;
@property(nonatomic, strong) NSArray* tips;
@property(nonatomic, strong) NSArray* paidTipsIds;

@end

@implementation LoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];

    UIFont* buttonFont = [UIFont fontWithName:@"Fishfingers" size:36];
    [self.showMeATipButton.titleLabel setFont:buttonFont];
    [self.showMeATipButton setHidden:YES];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self downloadFreeTipsAndPaidTipsIds];
}

-(void)downloadFreeTipsAndPaidTipsIds
{
    //[CommunicationManager sharedProvider] getPayedTipsIdentifiers:<#^(NSArray *tips, NSError *error)completion#>
    
    
    [[CommunicationManager sharedProvider] getDailyTips:^(NSArray *tips, NSError *error) {
        if (tips) {
            NSMutableArray* newTips = [NSMutableArray arrayWithCapacity:tips.count];
            for (NSString* tip in tips) {
                [newTips addObject:[NSString stringWithFormat:@"          %@",tip]];
            }
            self.tips = newTips;
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
    }
}

@end
