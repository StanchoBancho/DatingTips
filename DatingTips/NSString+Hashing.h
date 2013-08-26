//
//  NSString+Hashing.h
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/28/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hashing)

-(NSString*) stingToSHA1;
-(NSString *)stringToMD5String;

@end
