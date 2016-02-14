//
//  DebugManager.m

//
//  Created by Yang G on 14-5-19.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCDebugManager.h"
#import "DotCDebugManager+MockRequestRegiste.h"
#import "DotCDebugViewController.h"

@implementation DotCDebugManager

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _mockRequestDatabase     = STRONG_OBJECT(NSMutableDictionary, init);
    _mockRequestDataSelector = STRONG_OBJECT(NSMutableDictionary, init);
    
    _refreshDatabase = STRONG_OBJECT(NSMutableDictionary, init);
    _refreshRequestDataSelector = STRONG_OBJECT(NSMutableDictionary, init);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    [self registeMockRequest];
    [self registeRefreshMockRequest];
    
    {
        id instance = DOTC_DEBUG_VIEW_CONTROLLER;
    }
#pragma clang diagnostic pop
    
    return self;
}

- (void) dealloc
{
    [_mockRequestDatabase release];
    [_mockRequestDataSelector release];
    
    [_refreshDatabase release];
    [_refreshRequestDataSelector release];
    
    
    [super dealloc];
}


+ (instancetype) instance
{
#if defined APP_DEBUG
    static DotCDebugManager* s_instance = nil;
    APP_DISPATCH_ONCE(^{if(!s_instance) s_instance = STRONG_OBJECT(DotCDebugManager, init);});
    return s_instance;
#else
    return nil;
#endif
}

@end
