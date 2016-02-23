//
//  FileUtil.m
//  LibDotC
//
//  Created by Yang G on 14-10-21.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCFileUtil.h"
#import "DotCJSONConfig.h"

@implementation DotCFileUtil

+ (NSString*) readFile:(NSString*)fileName
{
    FILE* file   = NULL;
    char* buffer = NULL;
    NSString* ret = nil;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    
    if(!path)
    {
        return nil;
    }
    
    file = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "r");
    if(!file)
    {
        goto OPERATION_FAIL;
    }
    
    fseek(file, 0, SEEK_END);
    size_t len = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    buffer = (char*)malloc(len+1);
    if(fread(buffer, len, 1, file) != 1)
    {
        free(buffer);
        goto OPERATION_FAIL;
    }
    fclose(file);
    file = NULL;
    
    buffer[len] = 0;
    ret = [NSString stringWithUTF8String:buffer];
    
    free(buffer);
    buffer = NULL;
    
    return ret;
OPERATION_FAIL:
    if(file)
    {
        fclose(file);
        file = NULL;
    }
    
    return nil;
}

+ (DotCJSONConfig*) readJSONFile:(NSString*)fileName
{
    return [DotCJSONConfig configFromFile:fileName];
}

@end
