//
//  PathUtil.m
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "DotCPathUtil.h"

@implementation DotCPathUtil

+ (NSString*) cacheRoot
{
    NSArray*  paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = [paths[0] stringByAppendingPathComponent:@"dotc"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil  error:nil];
    }
    
    return path;
}

+ (NSString*) netCacheRoot
{
    return [[self cacheRoot] stringByAppendingPathComponent:@"netCache"];
}

+ (NSString*) databaseCacheRoot
{
    return [[self cacheRoot] stringByAppendingPathComponent:@"databaseCache"];
}
@end
