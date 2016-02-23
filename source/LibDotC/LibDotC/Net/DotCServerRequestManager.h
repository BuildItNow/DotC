//
//  RequestManager.h
//  DotC
//
//  Created by Yang G on 14-7-4.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@class DotCServerRequest;

@class DotCNetService;

@interface DotCServerRequestManager : AFHTTPRequestOperationManager

- (instancetype) initWithService:(DotCNetService*)service;

- (DotCServerRequest*) request:(NSString*)url option:(DotCServerRequestOption*)option;
- (void) cancelRequest:(DotCServerRequest*)request;
@end
