//
//  TipCell.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "TipCell.h"
#import <CoreText/CoreText.h>
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
    NSString* tipTitleWithSpaces = [NSString stringWithFormat:@"          %@",tipTitle];
    //set the text view
    [self.tipTextLabel setText:tipTitleWithSpaces];
    CGSize sizeOfTextField = CGSizeZero;
    if([tipTitleWithSpaces respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]){
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.tipTextLabel.font, NSFontAttributeName, nil];
        sizeOfTextField = [tipTitleWithSpaces boundingRectWithSize:CGSizeMake(190.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil].size;
    }
    else{
        sizeOfTextField = [tipTitleWithSpaces sizeWithFont:self.tipTextLabel.font constrainedToSize:CGSizeMake(190.0f, CGFLOAT_MAX)];
    }
    
    [self.tipTextLabel setText:tipTitleWithSpaces];
    CGRect frame = self.tipTextLabel.frame;
    frame.size.height = sizeOfTextField.height ;
    CGFloat difference = frame.size.height - self.tipTextLabel.frame.size.height;
    self.tipTextLabel.frame = frame;
    
    //set the container
    [self addValue:difference toHeightOfView:self.tipContainer];
    
    //set the tagslabel
    CGRect tagsLabelFrame = self.tagsLabel.frame;
    tagsLabelFrame.origin.y = containerViewOriginY + self.tipContainer.frame.size.height + spaceBetweenContainerAndTagsLabel;
    self.tagsLabel.frame = tagsLabelFrame;
}

+(CGFloat)cellHeightForTip:(NSString*)tipTitle
{
   NSString* tipTitleWithSpaces = [NSString stringWithFormat:@"          %@",tipTitle];

   UIFont* font = [UIFont systemFontOfSize:14.0f];
    CGSize sizeOfTextField = CGSizeZero;
    if([tipTitleWithSpaces respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]){
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        sizeOfTextField = [tipTitleWithSpaces boundingRectWithSize:CGSizeMake(190.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil].size;
    }
    else{
        sizeOfTextField = [tipTitleWithSpaces sizeWithFont:font constrainedToSize:CGSizeMake(190.0f, CGFLOAT_MAX)];
    }
    CGFloat result = containerViewOriginY + textViewOriginY + sizeOfTextField.height + textViewOffset + containerViewSpaceToBottom ;
    return result;

}
@end
