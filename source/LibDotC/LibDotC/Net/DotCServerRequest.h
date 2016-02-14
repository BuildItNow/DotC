//
//  BaseRequest+UserInfo.h

//
//  Created by Yang G on 14-5-14.
//  Copyright (c) 2014年 . C . All rights reserved.
//

@class DotCServerRequestOption;
@class DotCDictionaryWrapper;

extern NSString* INVALID_OPERATION;
extern NSString* INVALID_MODULE;

@interface DotCServerRequest : NSObject

- (NSMutableDictionary*) userDatas;
- (id) userData:(id) key;
- (void) setUserData:(id) data key:(id) key;
- (void) setOperation:(NSString*) operation module:(NSString*) module;
- (NSString*) operation;
- (NSString*) module;
- (void) setOption:(DotCServerRequestOption*) option;
- (DotCServerRequestOption*) option;
- (void) dumpDebugInfo;
- (NSInteger) httpStatusCode;
- (NSString*) httpDescription;
- (void) setError:(NSError*)error;
- (NSError*) error;
- (BOOL) isTimeout;
- (BOOL) isClientError;
- (BOOL) isServerError;
- (BOOL) isCancelled;

- (DotCDictionaryWrapper*) resHeaderFields;

@end

@interface MockRequest : DotCServerRequest
{
    id      _responseObject;
}

- (instancetype) init;
- (void) dealloc;

- (void) setResponseObject:(id) responseObject;
- (id)responseObject;
- (NSInteger) httpStatusCode;
- (NSString*) httpDescription;
@end