//
//  DebugManager.h

//
//  Created by Yang G on 14-5-19.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>

@class DotCServerRequestOption;

@interface DotCDebugManager : NSObject
{
    NSMutableDictionary*   _mockRequestDatabase;
    NSMutableDictionary*   _mockRequestDataSelector;
    NSMutableDictionary*   _refreshDatabase;
    NSMutableDictionary*   _refreshRequestDataSelector;
}

- (instancetype) init;
- (void) dealloc;

+ (instancetype) instance;

@end

#define DOTC_DEBUG_MANAGER [DotCDebugManager instance]
