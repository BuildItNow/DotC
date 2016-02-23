//
//  PathUtil.h
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCPathUtil : NSObject

+ (NSString*) cacheRoot;
+ (NSString*) netCacheRoot;
+ (NSString*) databaseCacheRoot;
@end
