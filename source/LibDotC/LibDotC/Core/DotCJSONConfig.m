//
//  JSONConfig.m
//  LibDotC
//
//  Created by Yang G on 14-10-21.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCJSONConfig.h"
#import "DotCFileUtil.h"
#import "JSONKit.h"
#import "DotCDictionaryUtil.h"

@implementation DotCJSONConfig

- (BOOL) load:(NSString*)fileName
{
    NSString* json = [DotCFileUtil readFile:fileName];
    if(!json)
    {
        return FALSE;
    }
    
    NSDictionary* dictionary = [DotCDictionaryUtil object:[json objectFromJSONString] to:[NSDictionary class]];
    if(!dictionary)
    {
        return FALSE;
    }
    
    [self setDictionary:dictionary];
    
    return TRUE;
}

- (DotCJSONConfig*) getSubConfig:(NSString*)name
{
    NSDictionary* dictionary = [DotCDictionaryUtil object:[self get:name] to:[NSDictionary class]];
    return [DotCJSONConfig configFromDictionary:dictionary];
}

+ (instancetype) configFromFile:(NSString*)fileName
{
    DotCJSONConfig* ret = WEAK_OBJECT(self, init);
    
    if(![ret load:fileName])
    {
        return nil;
    }
    
    return ret;
}

+ (instancetype) configFromDictionary:(NSDictionary*)dictionary
{
    if(!dictionary)
    {
        return nil;
    }
        
    return WEAK_OBJECT(DotCJSONConfig, initWith:dictionary);
}

+ (instancetype) globalConfig
{
    static DotCJSONConfig* s_instance= nil;
    if(!s_instance)
    {
        s_instance = [[self configFromFile:@"config.json"] retain];
    }
    
    return s_instance;
}

@end
