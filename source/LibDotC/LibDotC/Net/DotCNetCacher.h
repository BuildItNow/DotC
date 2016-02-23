//
//  NetCacher.h

//
//  Created by Yang G on 14-5-21.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DotCCache.h"

@interface DotCNetCacher : NSObject

- (void) save:(NSString*)url data:(id)data;
- (id)   cacheData:(NSString*)url;
- (void) clearAll;
- (void) clear:(NSString*)url;
- (void) clearCache:(float)daysAgo;
- (int)  getCacheSize;
@end

