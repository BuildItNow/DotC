//
//  DeviceUtil.m
//  LibDotC
//
//  Created by Yang G on 14-10-30.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCDeviceUtil.h"
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

@implementation DotCDeviceUtil

+ (EDeviceType)     deviceType
{
    switch(deviceDetails().model)
    {
        case GBDeviceModeliPhone4:
        {
            return DEVICE_IPHONE_4;
        }
        case GBDeviceModeliPhone4S:
        {
            return DEVICE_IPHONE_4S;
        }
        case GBDeviceModeliPhone5:
        {
            return DEVICE_IPHONE_5;
        }
        case GBDeviceModeliPhone5C:
        {
            return DEVICE_IPHONE_5C;
        }
        case GBDeviceModeliPhone5S:
        {
            return DEVICE_IPHONE_5S;
        }
        case GBDeviceModeliPhone6:
        {
            return DEVICE_IPHONE_6;
        }
        case GBDeviceModeliPhone6Plus:
        {
            return DEVICE_IPHONE_6PLUS;
        }
        case GBDeviceModeliPhoneSimulator:
        {
            return DEVICE_IPHONE_SIMULATOR;
        }
        default:
        {
            break;
        }
    }
    
    return DEVICE_UNKNOWN;
}

+ (EDeviceFamily)   deviceFamily
{
    switch(deviceDetails().family)
    {
        case GBDeviceFamilyiPhone:
        {
            return DEVICE_FAMILY_IPHONE;
        }
        case GBDeviceFamilyiPad:
        {
            return DEVICE_FAMILY_IPAD;
        }
        case GBDeviceFamilySimulator:
        {
            return DEVICE_FAMILY_SIMULATOR;
        }
        default:
        {
            break;
        }
    }
    
    return DEVICE_FAMILY_UNKNOWN;
}

+(NSString*) deviceTypeName
{
    switch([self deviceType])
    {
        case DEVICE_IPHONE_4:
        {
            return @"IPHONE4";
        }
        case DEVICE_IPHONE_4S:
        {
            return @"IPHONE4S";
        }
        case DEVICE_IPHONE_5:
        {
            return @"IPHONE5";
        }
        case DEVICE_IPHONE_5C:
        {
            return @"IPHONE5C";
        }
        case DEVICE_IPHONE_5S:
        {
            return @"IPHONE5S";
        }
        case DEVICE_IPHONE_6:
        {
            return @"IPHONE6";
        }
        case DEVICE_IPHONE_6PLUS:
        {
            return @"IPHONE6+";
        }
        case DEVICE_IPHONE_SIMULATOR:
        {
            return @"IPHONESIMULATOR";
        }
        default:
        {
            break;
        }
    }
    
    return @"UNKNOWN";
}

+ (BOOL) isDevice:(EDeviceType)type
{
    return [self deviceType] == type;
}

+ (BOOL) isDeviceFamily:(EDeviceFamily)family
{
    return [self deviceFamily] == family;
}

@end
