//
//  DictionaryUtil.m
//  DotC
//
//  Created by Yang G on 14-10-18.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "DotCDictionaryUtil.h"

@implementation DotCDictionaryUtil

+ (id) object:(id)object to:(Class)class
{
    if(!object)
    {
        return nil;
    }
    
    if([object isKindOfClass:[NSNull class]])
    {
        return nil;
    }
    
    if([object isKindOfClass:class])
    {
        return object;
    }
    
    Class CLASS_NUMBER = [NSNumber class];
    Class CLASS_STRING = [NSString class];
    
    if([class isSubclassOfClass:CLASS_STRING])  // to string
    {
        if([object isKindOfClass:CLASS_NUMBER])
        {
            return [((NSNumber*)object) stringValue];
        }
    }
    else if([class isSubclassOfClass:CLASS_NUMBER]) // to number
    {
        if([object isKindOfClass:CLASS_STRING])
        {
            static NSNumberFormatter* s_formater = nil;
            APP_DISPATCH_ONCE(^{if(!s_formater) s_formater = STRONG_OBJECT(NSNumberFormatter, init);[s_formater setNumberStyle:NSNumberFormatterDecimalStyle];});
            
            return [s_formater numberFromString:object];
        }
    }
    
    return nil;
}

+ (int64_t) objectToInteger:(id)object
{
    NSNumber* number = [self object:object to:[NSNumber class]];
    
    return number ? [number longLongValue] : 0;
}

+ (double) objectToDouble:(id)object
{
    NSNumber* number = [self object:object to:[NSNumber class]];
    
    return number ? [number doubleValue] : 0.0;
}

+ (int) objectToInt:(id)object
{
    NSNumber* number = [self object:object to:[NSNumber class]];
    
    return number ? [number intValue] : 0;
}

+ (float) objectToFloat:(id)object
{
    NSNumber* number = [self object:object to:[NSNumber class]];
    
    return number ? [number floatValue] : 0.0f;
}

+ (long) objectToLong:(id)object
{
    NSNumber* number = [self object:object to:[NSNumber class]];
    
    return number ? [number longValue] : 0L;
}

+ (BOOL) objectToBool:(id)object
{
    NSString* svalue = [DotCDictionaryUtil object:object to:[NSString class]];
    if(svalue)
    {
        svalue = [svalue lowercaseString];
        if([svalue isEqualToString:@"true"] || [svalue isEqualToString:@"yes"])
        {
            return TRUE;
        }
    }
    
    NSNumber* nvalue = [DotCDictionaryUtil object:object to:[NSNumber class]];
    return nvalue.boolValue;
}

@end
