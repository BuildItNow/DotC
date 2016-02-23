//
//  Defines.h
//  LibDotC
//
//  Created by Yang G on 14-10-20.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

// Create a weak object, that means you don't own the object resource, no need to release or autorelease.
#if __has_feature(objc_arc)

#define WEAK_OBJECT(class, initor)\
    [[[class alloc] initor]]

#else

#define WEAK_OBJECT(class, initor)\
    [[[class alloc] initor] autorelease]

#endif

// Create a strong object, that means you own the object resource, need release or autorelease.
#define STRONG_OBJECT(class, initor)\
[[class alloc] initor]

// Count the static c array
#define COUNT_OF(array) (sizeof(array)/sizeof(array[0]))

#define BIT(n) (1<<(n))

#if DEBUG
#   define APP_DEBUG
#endif

#if defined APP_DEBUG
#   define APP_ASSERT(value) assert(value)
#   define LOG_DBUG(msg, ...) {NSLog(msg, ##__VA_ARGS__);}
#else
#   define APP_ASSERT(value)
#   define LOG_DBUG(msg, ...)
#endif

#define LIB_TAG @"DOTC"

#define AF_VERSION_1_X
//#define AF_VERSION_2_X

#define APP_DISPATCH_ONCE(block)\
{\
static dispatch_once_t _;\
dispatch_once(&_, block);\
}
