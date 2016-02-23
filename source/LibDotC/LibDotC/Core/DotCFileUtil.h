//
//  FileUtil.h
//  LibDotC
//
//  Created by Yang G on 14-10-21.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

@class DotCJSONConfig;

@interface DotCFileUtil : NSObject

+ (NSString*) readFile:(NSString*)fileName;

+ (DotCJSONConfig*) readJSONFile:(NSString*)fileName;

@end
