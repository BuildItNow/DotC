//
//  SystemUtil.h
//  LibDotC
//
//  Created by Yang G on 14-10-22.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCSystemUtil : NSObject

+ (BOOL) aboveIOS5_0;
+ (BOOL) aboveIOS6_0;
+ (BOOL) aboveIOS7_0;
+ (BOOL) aboveIOS8_0;
+ (BOOL) aboveIOS:(float)version;

+ (NSString*) iosVersion;
+ (NSString*) mainVersion;
+ (NSString*) mainScreen;

@end
