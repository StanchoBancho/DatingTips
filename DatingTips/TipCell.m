//
//  TipCell.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "TipCell.h"

#define textViewOffset 5.0f
#define containerViewOriginY 35.0f
#define textViewOriginY 50.0f
#define textViewSpaceToBottom 15.0f
#define containerViewSpaceToBottom 50.0f
#define spaceBetweenContainerAndTagsLabel 10.0f

@interface TipCell ()


@end

@implementation TipCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    //set the resizable container image
    UIImage* tipContainerImage = [UIImage imageNamed:@"container"];
    tipContainerImage = [tipContainerImage resizableImageWithCapInsets:UIEdgeInsetsMake(60.0f, 0.0f, 40.0f, 0.0f)];
    [self.tipContainerBackground setImage:tipContainerImage];
    
    //set the label font
    UIFont* dayLabelFont = [UIFont fontWithName:@"Fishfingers" size:28];
    [self.dayLabel setFont:dayLabelFont];
}

-(void)addValue:(CGFloat)value toHeightOfView:(UIView*)view
{
    CGRect frame = view.frame;
    frame.size.height += value;
    [view setFrame:frame];
}

-(void)setupCellWithTip:(NSString*)tipTitle
{
    //set the text view
    UIFont* font = [UIFont systemFontOfSize:14.0f];
    CGSize sizeOfTextField = [tipTitle sizeWithFont:font constrainedToSize:CGSizeMake(190.0f, CGFLOAT_MAX)lineBreakMode:NSLineBreakByTruncatingTail];
    [self.tipTextView setText:tipTitle];
    CGRect frame = self.tipTextView.frame;
    frame.size.height = sizeOfTextField.height + textViewOffset;
    CGFloat difference = frame.size.height - self.tipTextView.frame.size.height;
    self.tipTextView.frame = frame;
    
    //set the container
    [self addValue:difference toHeightOfView:self.tipContainer];
    
    //set the tagslabel
    CGRect tagsLabelFrame = self.tagsLabel.frame;
    tagsLabelFrame.origin.y = containerViewOriginY + self.tipContainer.frame.size.height + spaceBetweenContainerAndTagsLabel;
    self.tagsLabel.frame = tagsLabelFrame;
    
}

+(CGFloat)cellHeightForTip:(NSString*)tipTitle
{
    UIFont* font = [UIFont systemFontOfSize:14.0f];
    CGSize sizeOfTextField = [tipTitle sizeWithFont:font constrainedToSize:CGSizeMake(190.0f, CGFLOAT_MAX)];
    CGFloat result = containerViewOriginY + textViewOriginY + sizeOfTextField.height + textViewOffset + containerViewSpaceToBottom;
    return result;
}
@end
