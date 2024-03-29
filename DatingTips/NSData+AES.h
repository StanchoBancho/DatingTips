/* * Objective-C Augments - A small, miscellaneous set of Objective-C String and Data
 * augmentations
 * Copyright (C) 2011- nicerobot
 *
 * This file is part of Objective-C Augments.
 *
 * Objective-C Augments is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Objective-C Augments is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Objective-C Augments.  If not, see <http://www.gnu.org/licenses/>.
 */



//#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSData (AES)

-(NSData*) encrypt:(NSData*) key;
-(NSData*) encryptWithString:(NSString*) key;
-(NSData*) encrypt:(NSData*) key withPadding:(CCOptions) options;
-(NSData*) encrypt:(NSData*) key withInitial:(NSData*) iv;
-(NSData*) encrypt:(NSData*) key withInitial:(NSData*) iv andPadding:(CCOptions) options;

-(NSData*) decrypt:(NSData*) key;
-(NSData*) decryptWithString:(NSString*) key;
-(NSData*) decrypt:(NSData*) key withPadding:(CCOptions) options;
-(NSData*) decrypt:(NSData*) key withInitial:(NSData*) iv;
-(NSData*) decrypt:(NSData*) key withInitial:(NSData*) iv andPadding:(CCOptions) options;

@end
