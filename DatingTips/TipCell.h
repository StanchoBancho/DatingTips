//
//  TipCell.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextView* tipTextView;
@property (nonatomic, strong) IBOutlet UIImageView* tipContainerBackground;
@property (nonatomic, strong) IBOutlet UIView* tipContainer;
@property (nonatomic, strong) IBOutlet UILabel* dayLabel;
@property (nonatomic, strong) IBOutlet UILabel* tagsLabel;

-(void)setupCellWithTip:(NSString*)tipTitle;
+(CGFloat)cellHeightForTip:(NSString*)tipTitle;
@end
