//
//  HistoryViewController.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/9/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "HistoryViewController.h"
#import "LoadingViewController.h"

@interface HistoryViewController ()


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

@end
