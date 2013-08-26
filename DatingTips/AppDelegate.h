//
//  AppDelegate.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/iAd.h"
@protocol BannerViewContainer <NSObject>

-(void)showBannerView:(ADBannerView*)bannerView;
-(void)hideBannerView:(ADBannerView*)bannerView;

@optional

-(void)banerViewActionWillBegin;
-(void)banerViewActionDidFinish;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, ADBannerViewDelegate>

@property (assign, nonatomic, readonly) BOOL isIphone5;
@property (strong, nonatomic) UIWindow *window;

@end
