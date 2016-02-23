//
//  NetCacher.m

//
//  Created by Yang G on 14-5-21.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCNetCacher.h"
#import "JSONKit.h"

static NSString* url2key(NSString* url)
{
    return [DotCEncryptionUtil md5:url];
}

enum
{
    EDATA_NULL   = -1,
    EDATA_NSDATA = 0,
    EDATA_DICTIONARY,
    EDATA_STRING,
    EDATA_ARRAY,
    EDATA_IMAGE
};

@interface DotCNetCacher()
{
    id<DotCCache>       _cacher;
}

@end

@implementation DotCNetCacher

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _cacher = [DotCDatabaseCache cacheFromName:@"netCache"];//[FileCache cacheFromPath:[PathUtil netCacheRoot]];
    [_cacher retain];
    
    return self;
}

- (void) dealloc
{
    [_cacher release];
    
    [super dealloc];
}

- (void) save:(NSString*)url data:(id)data
{
    if(!data)
    {
        return ;
    }
    
    int32_t dataType = EDATA_NULL;
    NSData* srcData = nil;
    
    if([data isKindOfClass:[NSData class]])
    {
        dataType = EDATA_NSDATA;
        srcData  = (NSData*)data;
    }
    else if([data isKindOfClass:[NSDictionary class]])
    {
        dataType = EDATA_DICTIONARY;
        srcData = [(NSDictionary*)data JSONData];
    }
    else if([data isKindOfClass:[DotCDictionaryWrapper class]])
    {
        dataType = EDATA_DICTIONARY;
        srcData = [((DotCDictionaryWrapper*)data).dictionary JSONData];
    }
    else if([data isKindOfClass:[NSString class]])
    {
        dataType = EDATA_STRING;
        srcData = [(NSString*)data dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if([data isKindOfClass:[NSArray class]])
    {
        dataType = EDATA_ARRAY;
        srcData = [(NSArray*)data JSONData];
    }
    else if([data isKindOfClass:[UIImage class]])
    {
        dataType = EDATA_IMAGE;
        srcData = UIImageJPEGRepresentation(data, 1.0);
        if(!srcData)
        {
            srcData = UIImagePNGRepresentation(data);
        }
    }
    else
    {
        APP_ASSERT(false && "Un-support type");
        
        return ;
    }
    
    int   size   = (int)(4+srcData.length);
    void* buffer = malloc(size);
    *((int32_t*)buffer) = dataType;
    memcpy(buffer+4, srcData.bytes, srcData.length);
    NSData* dstData = [NSData dataWithBytesNoCopy:buffer length:size];
    
    [_cacher save:url2key(url) data:dstData];
}

- (id) cacheData:(NSString*)url
{
    NSData* data = [_cacher cacheData:url2key(url)];
    if(!data)
    {
        return nil;
    }
    
    const void* buffer = data.bytes;
    NSData* srcData = [NSData dataWithBytes:((char*)buffer)+4 length:(data.length-4)];
    int32_t dataType = *(int32_t*)buffer;
    
    id dstData = nil;
    switch(dataType)
    {
        case EDATA_STRING:
        {
            dstData = [NSString stringWithUTF8String:(const char*)srcData.bytes];
        }
        break;
        case EDATA_NSDATA:
        {
            dstData = srcData;
        }
        break;
        case EDATA_IMAGE:
        {
            dstData = [UIImage imageWithData:srcData];
        }
        break;
        case EDATA_DICTIONARY:
        {
            dstData = [srcData objectFromJSONData];
            APP_ASSERT([dstData isKindOfClass:[NSDictionary class]]);
            
            dstData = [DotCDictionaryWrapper wrapperFromDictionary:dstData];
        }
        break;
        case EDATA_ARRAY:
        {
            dstData = [srcData objectFromJSONData];
            APP_ASSERT([dstData isKindOfClass:[NSArray class]]);
        }
        break;
        default:
        {
            APP_ASSERT(false && "Un-support type");
        }
        break;
    }
    
    return dstData;
}

- (void) clearAll
{
    [_cacher clearAll];
}

- (void) clear:(NSString*)url
{
    [_cacher clear:url2key(url)];
}

- (void) clearCache:(float)daysAgo
{
    if([_cacher respondsToSelector:@selector(clearCache:)])
    {
        return [_cacher clearCache:daysAgo];
    }
}

- (int)  getCacheSize
{
    if([_cacher respondsToSelector:@selector(getCacheSize)])
    {
        return [_cacher getCacheSize];
    }
    
    return 0;
}

@end
