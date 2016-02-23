//
//  ImageUtil.m
//  LibDotC
//
//  Created by Yang G on 14-10-23.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCImageUtil.h"
#import "DotCSystemUtil.h"

static DotCJSONConfig* imagesConfig()
{
    static DotCJSONConfig* s_instance = nil;
    if(!s_instance)
    {
        s_instance = [DotCJSONConfig configFromFile:@"images.json"];
        [s_instance retain];
    }
    
    return s_instance;
}

@implementation DotCImageUtil

+ (UIImage*) getImage:(NSString*)name
{
    NSArray* configs = [imagesConfig() getArray:name];
    if(!configs || configs.count == 0)
    {
        return [UIImage imageNamed:name];
    }
    
    NSString* newName = nil;
    static NSString* R_KEY = @"r";
    static NSString* S_KEY = @"s";
    static NSString* I_KEY = @"i";
    
    NSString* mainVersion = [DotCSystemUtil mainVersion];
    NSString* mainScreen  = [DotCSystemUtil mainScreen];
    BOOL rOK = FALSE;
    BOOL sOK = FALSE;
    for(NSDictionary* item in configs)
    {
        rOK = FALSE;
        sOK = FALSE;
        
        DotCDictionaryWrapper* config = item.wrapper;
        
        NSString* r = [config getString:R_KEY];
        NSString* s = [config getString:S_KEY];
    
        if([r characterAtIndex:0] == '*')
        {
            rOK = TRUE;
        }
        else
        {
            rOK = [r rangeOfString:mainScreen].location != NSNotFound;
        }
        
        if(!rOK)
        {
            continue;
        }
        
        if([s characterAtIndex:0] == '*')
        {
            sOK = TRUE;
        }
        else
        {
            NSArray* ss = [s componentsSeparatedByString:@"|"];
            for(NSString* v in ss)
            {
                if([v isEqualToString:mainVersion])
                {
                    sOK = TRUE;
                    break;
                }
            }
        }
        
        if(!sOK)
        {
            continue;
        }
        
        newName = [config getString:I_KEY];
        break;
    }
    
    if(!newName)
    {
        newName = name;
    }
    
    return [UIImage imageNamed:newName];
}

@end
