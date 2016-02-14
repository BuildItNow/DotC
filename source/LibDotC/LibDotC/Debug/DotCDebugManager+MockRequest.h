//
//  DebugManager+MockRequest.h

//
//  Created by Yang G on 14-5-20.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCDebugManager.h"

@interface DotCDebugManager (MockRequest)

- (NSString*) generateRequestKey:(NSString*)operation module:(NSString*)module;
- (BOOL) isMockRequest:(NSString*)operation module:(NSString*)module option:(DotCServerRequestOption*)option;

@end
