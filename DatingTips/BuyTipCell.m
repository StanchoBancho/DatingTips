//
//  BuyTipCell.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/12/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "BuyTipCell.h"

@implementation BuyTipCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    UIFont* buttonFont = [UIFont fontWithName:@"Fishfingers" size:36];
    [self.getAnotherButton.titleLabel setFont:buttonFont];
}

@end
