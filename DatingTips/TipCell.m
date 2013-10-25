//
//  TipCell.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/11/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "TipCell.h"
#import <CoreText/CoreText.h>
#import "Tag.h"

#define textViewOffset 5.0f
#define containerViewOriginY 35.0f
#define textViewOriginY 50.0f
#define textViewSpaceToBottom 15.0f
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

-(void)setupCellWithTip:(NSString*)tipTitle andTags:(NSSet*)tags
{
    //set the text view
    NSString* tipTitleWithSpaces = [NSString stringWithFormat:@"          %@",tipTitle];
    [self.tipTextLabel setText:tipTitleWithSpaces];
    CGSize sizeOfTextField = CGSizeZero;
    
    //set the tags label
    NSString* tagsString = [TipCell tagsStringFromTags:tags];
    [self.tagsLabel setText:tagsString];
    CGSize sizeOfTagsLabel = CGSizeZero;
    
    if([tipTitleWithSpaces respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]){
        //get the size of the tip title
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.tipTextLabel.font, NSFontAttributeName, nil];
        sizeOfTextField = [tipTitleWithSpaces boundingRectWithSize:CGSizeMake(190.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil].size;
        sizeOfTextField.height = ceil(sizeOfTextField.height);
        
        //get the size of the tags
        attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.tagsLabel.font, NSFontAttributeName, nil];
        sizeOfTagsLabel = [tagsString boundingRectWithSize:CGSizeMake(267.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil].size;
        sizeOfTagsLabel.height = ceil(sizeOfTagsLabel.height);

    }
    else{
        //get the size of the tip title
        sizeOfTextField = [tipTitleWithSpaces sizeWithFont:self.tipTextLabel.font constrainedToSize:CGSizeMake(190.0f, CGFLOAT_MAX)];
        
        //get the size of the tags
        sizeOfTagsLabel = [tagsString sizeWithFont:self.tagsLabel.font constrainedToSize:CGSizeMake(267.0f, CGFLOAT_MAX)];
    }
    
    CGRect frame = self.tipTextLabel.frame;
    frame.size.height = sizeOfTextField.height ;
    CGFloat difference = frame.size.height - self.tipTextLabel.frame.size.height;
    self.tipTextLabel.frame = frame;
    
    //set the container
    [self addValue:difference toHeightOfView:self.tipContainer];
    
    //set the tagslabel
    CGRect tagsLabelFrame = self.tagsLabel.frame;
    tagsLabelFrame.origin.y = containerViewOriginY + self.tipContainer.frame.size.height + spaceBetweenContainerAndTagsLabel;
    tagsLabelFrame.size.height = sizeOfTagsLabel.height;
    self.tagsLabel.frame = tagsLabelFrame;
}

+(NSString*)tagsStringFromTags:(NSSet*)tags
{
    NSMutableString* tagsString = [[NSMutableString alloc] initWithString:@"tags: "];
    NSInteger i = 0;
    for (Tag* aTag in tags) {
        [tagsString appendFormat:@"%@ ", aTag.tagTitle];
        if(i != [tags count] - 1){
            [tagsString appendString:@"| "];
        }
        i++;
    }
    return tagsString;
}

+(CGFloat)cellHeightForTip:(NSString*)tipTitle andTags:(NSSet*)tags
{
    NSString* tipTitleWithSpaces = [NSString stringWithFormat:@"          %@",tipTitle];
    UIFont* font = [UIFont systemFontOfSize:14.0f];
    CGSize sizeOfTextField = CGSizeZero;
    
    NSString* tagsString = [TipCell tagsStringFromTags:tags];
    UIFont* tagsfont = [UIFont systemFontOfSize:18.0f];
    CGSize sizeOfTagsLabel = CGSizeZero;
    
    if([tipTitleWithSpaces respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]){
        //get the size of the tip title
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        sizeOfTextField = [tipTitleWithSpaces boundingRectWithSize:CGSizeMake(190.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil].size;
        sizeOfTextField.height = ceil(sizeOfTextField.height);
        
        //get the size of the tags
        attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:tagsfont, NSFontAttributeName, nil];
        sizeOfTagsLabel = [tagsString boundingRectWithSize:CGSizeMake(267.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDictionary context:nil].size;
        sizeOfTagsLabel.height = ceil(sizeOfTagsLabel.height);
    }
    else{
        //get the size of the tip title
        sizeOfTextField = [tipTitleWithSpaces sizeWithFont:font constrainedToSize:CGSizeMake(190.0f, CGFLOAT_MAX)];
        
        //get the size of the tags
        sizeOfTagsLabel = [tagsString sizeWithFont:tagsfont constrainedToSize:CGSizeMake(267.0f, CGFLOAT_MAX)];
        
    }
    CGFloat result = containerViewOriginY + textViewOriginY + sizeOfTextField.height + textViewOffset + spaceBetweenContainerAndTagsLabel+ sizeOfTagsLabel.height +12.0;
    return result;

}
@end
