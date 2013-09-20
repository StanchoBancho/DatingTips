//
//  AppDelegate.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "AppDelegate.h"
@interface AppDelegate()<UINavigationControllerDelegate>

@property(nonatomic, strong) ADBannerView* bannerView;
@property(nonatomic, strong) UIViewController<BannerViewContainer> *currentController;

@end

@implementation AppDelegate

-(BOOL)isIphone5
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
//    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    return  screenHeight == 568.0f;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //pop to the root
    UINavigationController* navigationViewController = (UINavigationController*)self.window.rootViewController;
    [navigationViewController popToRootViewControllerAnimated:NO];
    [navigationViewController setDelegate:self];
   // [self.window makeKeyAndVisible];

    //setup the banner view
    self.bannerView = [[ADBannerView alloc] init];
    CGRect frame = [self.bannerView frame];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    frame.origin = CGPointMake(CGRectGetMinX(screenBounds), CGRectGetMaxY(screenBounds));
    [self.bannerView setFrame:frame];
    [self.bannerView setDelegate:self];
    self.currentController = (UIViewController<BannerViewContainer>*)navigationViewController.visibleViewController;
    
//    NSLog(@"isIphone 5 %d",[self isIphone5]);
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Navigation Controller Delegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(self.currentController == viewController){
        return;
    }
    if(self.bannerView.bannerLoaded){
        [self.currentController hideBannerView:self.bannerView];
        [(UIViewController<BannerViewContainer>*)viewController showBannerView:self.bannerView];
    }
    self.currentController = (UIViewController<BannerViewContainer>*)viewController;
}

#pragma mark - ADBannerViewDelegate

- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
//    NSLog(@"%s",__FUNCTION__);
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"%s",__FUNCTION__);
    [self.currentController showBannerView:banner];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"%s %@",__FUNCTION__, error);
    [self.currentController hideBannerView:banner];
}

// This message will be sent when the user taps on the banner and some action is to be taken.
// Actions either display full screen content in a modal session or take the user to a different
// application. The delegate may return NO to block the action from taking place, but this
// should be avoided if possible because most advertisements pay significantly more when
// the action takes place and, over the longer term, repeatedly blocking actions will
// decrease the ad inventory available to the application. Applications may wish to pause video,
// audio, or other animated content while the advertisement's action executes.
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    if([self.currentController respondsToSelector:@selector(banerViewActionWillBegin)]){
        [self.currentController banerViewActionWillBegin];
    }
    return YES;
}

// This message is sent when a modal action has completed and control is returned to the application.
// Games, media playback, and other activities that were paused in response to the beginning
// of the action should resume at this point.
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    if([self.currentController respondsToSelector:@selector(banerViewActionDidFinish)]){
        [self.currentController banerViewActionDidFinish];
    }
}


@end
