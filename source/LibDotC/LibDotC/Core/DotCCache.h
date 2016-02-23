//
//  Cache.h
//  DotC
//
//  Created by Yang G on 14-7-5.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DotCCache <NSObject>
- (void)    save:(NSString*)key data:(NSData*)data;
- (NSData*) cacheData:(NSString*)key;
- (void)    clear:(NSString*)key;
- (void)    clearAll;

@optional
- (void)    clearCache:(float)daysAgo;
- (int)     getCacheSize;

@end

@interface DotCFileCache : NSObject<DotCCache>
- (void)    save:(NSString*)key data:(NSData*)data;
- (NSData*) cacheData:(NSString*)key;
- (void)    clear:(NSString*)key;
- (void)    clearAll;

+ (instancetype) cacheFromPath:(NSString*)path;
@end

@interface DotCDatabaseCache : NSObject<DotCCache>
- (void)    save:(NSString*)key data:(NSData*)data;
- (NSData*) cacheData:(NSString*)key;
- (void)    clear:(NSString*)key;
- (void)    clearAll;
- (void)    clearCache:(float)daysAgo;
- (int)     getCacheSize;

+ (instancetype) cacheFromName:(NSString*)name;
@end