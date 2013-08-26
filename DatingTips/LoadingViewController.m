//
//  ViewController.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "LoadingViewController.h"
#import "AppDelegate.h"
#import "CommunicationManager.h"
#import "HomeViewController.h"

@interface LoadingViewController ()<BannerViewContainer>

@property(nonatomic, assign) ADBannerView* bannerView;
@property(nonatomic, strong) IBOutlet UIView* contentView;
@property(nonatomic, strong) IBOutlet UIImageView* backgroundView;
@property(nonatomic, strong) IBOutlet UIButton* showMeATipButton;
@property(nonatomic, strong) NSArray* tips;
@end

@implementation LoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];

    UIImage* background = nil;
    BOOL isIphone5 = [(AppDelegate*)[[UIApplication sharedApplication] delegate] isIphone5];
    if (isIphone5) {
        background = [UIImage imageNamed:@"Default"];
    }
    else{
        background = [UIImage imageNamed:@"Default-568h"];
    }
    [self.backgroundView setImage:background];

    UIFont* buttonFont = [UIFont fontWithName:@"Fishfingers" size:36];
    [self.showMeATipButton.titleLabel setFont:buttonFont];
    [self.showMeATipButton setHidden:YES];
    [self layoutForCurrentOrientation:NO];
	// Do any additional setup after loading the view, typically from a nib.
    [self startSession];
}

-(void)startSession
{
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutForCurrentOrientation:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)layoutForCurrentOrientation:(BOOL)animated
{
    CGFloat animationDuration = animated? 0.2f : 0.0f;
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
        self.contentView.frame = contentFrame;
        [self.contentView layoutIfNeeded];
        self.bannerView.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, self.bannerView.frame.size.width, bannerHeigh);
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ShowHomeViewControllerSegue"]){
        [(HomeViewController*)segue.destinationViewController setDataSource:self.tips];
    }
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

//@optional
//
//-(void)banerViewActionWillBegin;
//-(void)banerViewActionDidFinish;


@end
