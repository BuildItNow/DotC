//
//  JSONConfig.h
//  LibDotC
//
//  Created by Yang G on 14-10-21.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCDictionaryWrapper.h"

@interface DotCJSONConfig : DotCDictionaryWrapper

- (DotCJSONConfig*) getSubConfig:(NSString*)name;

+ (instancetype) configFromFile:(NSString*)filePath;

+ (instancetype) globalConfig;

@end

#define DOTC_GLOBAL_CONFIG [DotCJSONConfig globalConfig]

