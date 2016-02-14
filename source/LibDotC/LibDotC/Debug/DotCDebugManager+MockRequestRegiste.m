//
//  DebugManager+MockRequestRegiste.m

//
//  Created by Yang G on 14-5-20.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCDebugManager+MockRequestRegiste.h"
#import "DotCDebugManager+MockRequest.h"

#define TURN_ON  TRUE
#define TURN_OFF FALSE

#define TEST_DATA_CASE(name, switch) if(switch)

#define REGISTE_SOURCE_DATA(n, d)\
{\
assert([_mockRequestDatabase objectForKey:n] == nil);\
[_mockRequestDatabase setObject:d forKey:n];\
}

#define REGISTE_MOCK_REQUEST(o, m, n)\
{\
assert([_mockRequestDataSelector objectForKey:[self generateRequestKey:o module:m]] == nil);\
[_mockRequestDataSelector setObject:n forKey:[self generateRequestKey:o module:m]];\
}

#define MESSAGE_VERSION_2_0 @"2.0"
#define MESSAGE_VERSION_2_1 @"2.1"
#define MESSAGE_VERSION_0_0 @"0.0"

@implementation DotCDebugManager (MockRequestRegiste)

- (void) registeMockRequest
{
}

#define REGISTE_REFRESH_DATA(n, d)\
{\
assert([_refreshDatabase objectForKey:n] == nil);\
[_refreshDatabase setObject:d forKey:n];\
}

#define REGISTE_REFRESH_MOCK_REQUEST(rn, dn)\
{\
assert([_refreshRequestDataSelector objectForKey:rn] == nil);\
[_refreshRequestDataSelector setObject:dn forKey:rn];\
}
- (void) registeRefreshMockRequest
{
}

@end

#undef REGISTE_SOURCE_DATA
#undef REGISTE_MOCK_REQUEST
