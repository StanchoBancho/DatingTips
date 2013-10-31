//
//  IAPManager.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/13/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "IAPManager.h"
#import "CommunicationManager.h"
#import "CoreDataManager.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

@interface IAPManager ()<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation IAPManager
{
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

#pragma mark - Public Methods

+ (IAPManager *)sharedInstance {
    static dispatch_once_t once;
    static IAPManager * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.stanimirnikolov.datingtips.onetip",
                                      @"com.stanimirnikolov.datingtips.seventips",
                                      @"com.stanimirnikolov.datingtips.fourteentips",
                                      @"com.stanimirnikolov.datingtips.thirtytips",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@...", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
    NSArray* sortedProducts = [skProducts sortedArrayUsingDescriptors:@[descriptor]];
    _completionHandler(YES, sortedProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

- (void)provideContentForTransaction:(SKPaymentTransaction*)transaction
{
    
    NSData* receiptData = nil;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        receiptData = [transaction transactionReceipt];
    } else {
        // Load resources for iOS 7 or later
        receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    }
    NSString *productIdentifier = transaction.payment.productIdentifier;

    //make request for productIdentifier with receipt data
    [[CommunicationManager sharedProvider] getPayedTipsWithReceiptData:receiptData andCopletion:^(NSArray *tips, NSDate *forDate, NSError *error) {
        
        if (tips && forDate) {
            [[CoreDataManager sharedManager] updateTipsWithJSONArray:tips forDate:forDate];

//            [_purchasedProductIdentifiers addObject:productIdentifier];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }        
    }];
    
    
    
    
}

#pragma mark - Utility methods

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    [self provideContentForTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    [self provideContentForTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark - SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}


@end
