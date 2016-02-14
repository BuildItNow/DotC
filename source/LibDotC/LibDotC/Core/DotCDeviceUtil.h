//
//  DeviceUtil.h
//  LibDotC
//
//  Created by Yang G on 14-10-30.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

typedef enum
{
    DEVICE_UNKNOWN = 0,
    DEVICE_IPHONE_4,
    DEVICE_IPHONE_4S,
    DEVICE_IPHONE_5,
    DEVICE_IPHONE_5C,
    DEVICE_IPHONE_5S,
    DEVICE_IPHONE_6,
    DEVICE_IPHONE_6PLUS,
    DEVICE_IPHONE_SIMULATOR,
}EDeviceType;

typedef enum
{
    DEVICE_FAMILY_UNKNOWN = 0,
    DEVICE_FAMILY_IPHONE,
    DEVICE_FAMILY_IPAD,
    DEVICE_FAMILY_SIMULATOR,
}EDeviceFamily;

@interface DotCDeviceUtil : NSObject

+ (EDeviceType)     deviceType;
+ (EDeviceFamily)   deviceFamily;
+ (BOOL) isDevice:(EDeviceType)type;
+ (BOOL) isDeviceFamily:(EDeviceFamily)family;

+(NSString*) deviceTypeName;

@end
