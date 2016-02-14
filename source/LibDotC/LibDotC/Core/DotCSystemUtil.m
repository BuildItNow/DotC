//
//  SystemUtil.m
//  LibDotC
//
//  Created by Yang G on 14-10-22.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCSystemUtil.h"
#import "GBDeviceInfo.h"

static GBDeviceDetails* deviceDetails()
{
    static GBDeviceDetails* s_instsance = nil;
    if(!s_instsance)
    {
        s_instsance = [GBDeviceInfo deviceDetails];
        [s_instsance retain];
    }
    
    return s_instsance;
}

@implementation DotCSystemUtil

+ (BOOL) aboveIOS5_0
{
    return [self aboveIOS:5.0f];
}

+ (BOOL) aboveIOS6_0
{
    return [self aboveIOS:6.0f];
}

+ (BOOL) aboveIOS7_0
{
    return [self aboveIOS:7.0f];
}

+ (BOOL) aboveIOS8_0
{
    return [self aboveIOS:8.0f];
}

+ (BOOL) aboveIOS:(float)version
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= version;
}

+ (NSString*) iosVersion
{
    static NSString* s_value = nil;
    if(!s_value)
    {
        s_value = [NSString stringWithFormat:@"%@.%@", [self mainVersion], [self subVersion]];
        [s_value retain];
    }
    
    return s_value;;
}

+ (NSString*) mainVersion
{
    static NSString* s_value = nil;
    if(!s_value)
    {
        s_value = [NSString stringWithFormat:@"%ld", (unsigned long)deviceDetails().majoriOSVersion];
        [s_value retain];
    }
    
    return s_value;
}

+ (NSString*) subVersion
{
    static NSString* s_value = nil;
    if(!s_value)
    {
        s_value = [NSString stringWithFormat:@"%ld", (unsigned long)deviceDetails().minoriOSVersion];
        [s_value retain];
    }
    
    return s_value;
}

+ (NSString*) mainScreen
{
    static NSString* s_value = nil;
    if(!s_value)
    {
        CGSize size = [UIScreen mainScreen].bounds.size;
        
        int w = (int)size.width;
        int h = (int)size.height;
        
        s_value = [NSString stringWithFormat:@"%dx%d", w, h];
        [s_value retain];
    }
    
    return s_value;
}

@end
