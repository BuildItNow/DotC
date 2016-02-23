//
//  BaseRequest+UserInfo.m

//
//  Created by Yang G on 14-5-14.
//  Copyright (c) 2014年 .C. All rights reserved.
//

#import "DotCServerRequest.h"
#import "JSONKit.h"
#import "AFNetworking.h"

NSString* INVALID_OPERATION = @"INVALID_OPERATION";
NSString* INVALID_MODULE    = @"INVALID_MODULE";

@interface DotCServerRequest()
{
    AFHTTPRequestOperation*   _requestOperation;
    
    NSString*               _operation;
    NSString*               _module;
    NSMutableDictionary*    _userDatas;
        
    NSError*                _error;
}

@end

@implementation DotCServerRequest

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _operation = INVALID_OPERATION;
    _module    = INVALID_MODULE;
    
    _userDatas = STRONG_OBJECT(NSMutableDictionary, init);
    
    return self;
}

- (void) dealloc
{
    [_error release];
    [_module release];
    [_userDatas release];
    [_requestOperation release];
    
    [super dealloc];
}

- (NSMutableDictionary*) userDatas
{
    return _userDatas;
}

- (id) userData:(id) key
{
    return [_userDatas objectForKey:key];
}

- (void) setUserData:(id) object key:(id) key
{
    [_userDatas setObject:object forKey:key];
}

- (void) setOperation:(NSString*) operation module:(NSString *)module
{
    [_operation autorelease];
    [_module autorelease];
    
    _operation = [operation copy];
    _module    = [module copy];
}

- (NSString*) operation
{
    return _operation;
}

- (NSString*) module
{
    return _module;
}

- (void) setOption:(DotCServerRequestOption*) option
{
    [self setUserData:option key:@"option"];
}

- (DotCServerRequestOption*) option
{
    return [self userData:@"option"];
}

- (void) dumpDebugInfo
{
    DotCServerRequestOption* option = self.option;
    
    NSString* fromWhere = @"Server";
    if([[self userData:@"mock"] isEqualToString:@"yes"])
    {
        fromWhere = @"Mock";
    }
    else if([[self userData:@"fromCache"] isEqualToString:@"yes"])
    {
        fromWhere = @"Cache";
    }
    else if([[self userData:@"fromCacheUpdate"] isEqualToString:@"yes"])
    {
        fromWhere = @"CacheUpdate";
    }
    
    
    NSString* debugInfo = [NSString stringWithFormat:@"URL : %@\nHTTP status : %ld HTTP desc : %@\nFrom : %@\nModule : %@ Operation : %@",
                           option.url,
                           (long)self.httpStatusCode, self.httpDescription,
                           fromWhere,
                           self.module, self.operation
                           ];
    
    NSDictionary* cookies = [DOTC_NET_SERVICE httpCookiesForURL:option.url];
    NSMutableString* cookiesInfo = WEAK_OBJECT(NSMutableString, init);
    for(NSString* key in cookies.allKeys)
    {
        [cookiesInfo appendFormat:cookiesInfo.length ? @"\n%@ = %@" : @"%@ = %@", key, [cookies valueForKey:key]];
    }
    
    NSString* note = @"********HTTP*************";
    
    NSLog(@"\n%@\n%@\n=========Cookies===========\n%@\n%@", note, debugInfo, cookiesInfo, note);
}

- (void) setError:(NSError*)error
{
    [_error autorelease];
    
    _error = [error retain];
}

- (NSError*) error
{
    return _error;
}

- (BOOL) isTimeout
{
    return _error && _error.code == NSURLErrorTimedOut;
}

- (BOOL) isClientError
{
    return self.httpStatusCode >= 400 && self.httpStatusCode < 500;
}

- (BOOL) isServerError
{
    return self.httpStatusCode >= 500 && self.httpStatusCode < 600;
}

- (BOOL) isCancelled
{
    return _error && _error.code == NSURLErrorCancelled;
}

- (void) setupOperation:(AFHTTPRequestOperation*)requestOperation
{
    _requestOperation = requestOperation;
}

- (void) deSetupOperation
{
    _requestOperation = nil;
}

- (AFHTTPRequestOperation*) httpOperation
{
    return _requestOperation;
}

- (NSInteger) httpStatusCode
{
    return _requestOperation.response.statusCode;
}

- (NSString*) httpDescription
{
    return [NSHTTPURLResponse localizedStringForStatusCode:self.httpStatusCode];
}

- (DotCDictionaryWrapper*) resHeaderFields
{
    return _requestOperation.response.allHeaderFields.wrapper;
}

@end

@implementation MockRequest

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    return self;
}

- (void) dealloc
{
    [_responseObject release];
    
    [super dealloc];
}

- (NSInteger) httpStatusCode
{
    return 200;
}

- (NSString*) httpDescription
{
    return [NSHTTPURLResponse localizedStringForStatusCode:200];
}

- (void) setResponseObject:(id)responseObject
{
    [_responseObject release];
    
    _responseObject = [responseObject retain];
}

- (id)responseObject
{
    return _responseObject;
}

@end
