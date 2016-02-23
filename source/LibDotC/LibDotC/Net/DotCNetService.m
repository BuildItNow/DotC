//
//  Common+Net.m

//
//  Created by Yang G on 14-5-15.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCNetService.h"
#import "DotCNetService+Dispatcher.h"
#import "DotCServerRequest.h"
#import "DotCServerRequestManager.h"
#import "DotCDebugManager.h"
#import "DotCDebugManager+MockRequest.h"
#import "DotCNetCacher.h"
#import "Reachability.h"

extern NSString * AFQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);

static NSString* queryStringFromParameters(NSDictionary *parameters)
{
    return AFQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding);
}

static ENetStatus reachStatus2NetStataus(DotCNetworkStatus status)
{
    switch(status)
    {
        case NotReachable:
        {
            return NET_STATUS_DOWN;
        }
        case ReachableViaWiFi:
        {
            return NET_STATUS_WIFI;
        }
        case ReachableViaWWAN:
        {
            return NET_STATUS_WWAN;
        }
        default:
        {
            return NET_STATUS_UNKNOWN;
        }
    }
    
    return NET_STATUS_UNKNOWN;
}

// Net delegator arguments keys
NSString* NET_ARGUMENT_OPERATION = @"NET_ARGUMENT_OPERATION";
NSString* NET_ARGUMENT_MODULE = @"NET_ARGUMENT_MODULE";
NSString* NET_ARGUMENT_OPTION = @"NET_ARGUMENT_OPTION";
NSString* NET_ARGUMENT_REQUEST = @"NET_ARGUMENT_REQUEST";
NSString* NET_ARGUMENT_RETOBJECT = @"NET_ARGUMENT_RETOBJECT";
NSString* NET_ARGUMENT_ERROR = @"NET_ARGUMENT_ERROR";

// Net options
NSString* OPTION_CHECK_OPERATION_DUPLICATION = @"OPTION_CHECK_OPERATION_DUPLICATION";
NSString* OPTION_CHECK_URL_DUPLICATION = @"OPTION_CHECK_URL_DUPLICATION";
NSString* OPTION_NEED_CACHE = @"OPTION_NEED_CACHE";
NSString* OPTION_NEED_HANDLE_ERROR = @"OPTION_NEED_HANDLE_ERROR";
NSString* OPTION_NEED_LOADING_INDICATOR = @"OPTION_NEED_LOADING_INDICATOR";
NSString* OPTION_NEED_CACHE_UPDATE = @"OPTION_NEED_CACHE_UPDATE";
NSString* OPTION_NEED_DEBUG_INFO = @"OPTION_NEED_DEBUG_INFO";

NSString* OPTION_REQUEST_NEVER_FILTERED = @"OPTION_REQUEST_NEVER_FILTERED";
NSString* OPTION_REQUEST_FILTERED = @"OPTION_REQUEST_FILTERED";

NSString* NET_EVENT_RESPONSE = @"NET_EVENT_RESPONSE";
NSString* NET_EVENT_REQUEST = @"NET_EVENT_REQUEST";
NSString* NET_EVENT_NET_STATUS_CHANGE = @"NET_EVENT_NET_STATUS_CHANGE";
NSString* NET_EVENT_ARGUMENT_NET_STATUS = @"NET_EVENT_ARGUMENT_NET_STATUS";
NSString* NET_EVENT_ARGUMENT_NET_OLD_STATUS = @"NET_EVENT_ARGUMENT_NET_OLD_STATUS";

static NSString* url2key(NSString* url)
{
    return [DotCEncryptionUtil md5:url];
}

static NSString* operation2key(NSString* operation, NSString* module)
{
    return [NSString stringWithFormat:@"%@#%@", operation, module];
}

@interface CachedRequest : MockRequest
{

}

+ (instancetype) requestFromUrl:(NSString*) url cacheData:(id)data;

@end

@implementation CachedRequest

+ (instancetype) requestFromUrl:(NSString*) url cacheData:(id)data
{
    CachedRequest* request = WEAK_OBJECT(self, init);
    
    [request setResponseObject:data];

    return request;
}

@end

@interface DotCServerRequestOption()
{
    BOOL                    _useCustomHeadParams;
    NSMutableDictionary*    _headParams;
    NSMutableDictionary*    _options;
}
@end

@implementation DotCServerRequestOption

@synthesize requestType = _requestType;

- (instancetype) init
{
    self = [super init];
    
    if(!self)
    {
        return self;
    }
    
    _requestType            = REQUEST_GET;
    _useCustomHeadParams    = FALSE;
    _options                = STRONG_OBJECT(NSMutableDictionary, init);
    
    return self;
}

- (void) dealloc
{
    [_headParams release];
    [_options release];
    
    [super dealloc];
}

- (instancetype) copyWithZone:(NSZone *)zone
{
    DotCServerRequestOption* ret = [[DotCServerRequestOption allocWithZone:zone] init];
    
    ret->_requestType = _requestType;
    ret->_useCustomHeadParams = _useCustomHeadParams;
    if(_headParams)
    {
        ret->_headParams = STRONG_OBJECT(NSMutableDictionary, initWithDictionary:_headParams);
    }
    [ret->_options addEntriesFromDictionary:_options];
    
    return ret;
}

- (void) setServer:(NSString*)server
{
    if(server)
    {
        [_options setObject:server forKey:@"server"];
    }
    else
    {
        [_options removeObjectForKey:@"server"];
    }
}

- (NSString*) server
{
    NSString* ret = [_options objectForKey:@"server"];
    if(!ret)
    {
        ret = [DOTC_DELEGATE.versionConfig getString:@"SERVER"];
    }
    
    return ret;
}

- (void) setService:(NSString*)service;
{
    if(service)
    {
        if([service hasPrefix:@"/"])
        {
            NSRange range;
            range.location = 0;
            range.length = 1;
            service = [service stringByReplacingCharactersInRange:range withString:@""];
        }
        
        [_options setObject:service forKey:@"service"];
    }
    else
    {
        [_options removeObjectForKey:@"service"];
    }
}

- (void) setParameters:(NSDictionary*)parameters
{
    if(parameters)
    {
        [_options setObject:parameters forKey:@"parameters"];
    }
    else
    {
        [_options removeObjectForKey:@"parameters"];
    }
}

- (NSString*) service
{
    return [_options objectForKey:@"service"];
}

- (NSDictionary*) parameters
{
    return [_options objectForKey:@"parameters"];
}

- (BOOL) isGet
{
    return _requestType == REQUEST_GET;
}

- (BOOL) isPost
{
    return _requestType == REQUEST_POST;
}

- (void) setRequestType:(ERequestType) requestType
{
    _requestType = requestType;
}

- (NSString*) url
{
    NSMutableString* url = [NSMutableString stringWithString:self.server];
    NSString* service = self.service;
    if(service)
    {
        [url appendString:service];
    }
    
    NSDictionary* parameters = self.parameters;
    if(parameters)
    {
        NSString* query = queryStringFromParameters(parameters);
        NSString* main  = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL*    nsURL = [NSURL URLWithString:main];
        
        return [main stringByAppendingFormat:(nsURL.query ? @"&%@" : @"?%@"), query];
    }
    else
    {
        return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

- (float) timeoutInterval
{
    return [_options.wrapper getFloat:@"timeout"];    
}

- (void) setTimeoutInterval:(float)time
{
    [_options setObject:@(time) forKey:@"timeout"];
}

- (void) setBody:(id)body
{
    assert(body);
    
    [_options setObject:body forKey:@"body"];
}

- (id) body
{
    return [_options valueForKey:@"body"];
}

- (NSDictionary*) headParams
{
    if(!_headParams)
    {
        return [DotCServerRequestOption defaultHeadParams];
    }
    
    if(_useCustomHeadParams)
    {
        return _headParams;
    }
    
    NSMutableDictionary* ret = [NSMutableDictionary dictionaryWithDictionary:[DotCServerRequestOption defaultHeadParams]];
    
    [ret addEntriesFromDictionary:_headParams];
    
    return ret;
}

- (void) setHeadParams:(NSDictionary*) headParams
{
    [_headParams autorelease];
    _headParams = nil;
    
    if(!headParams)
    {
        _useCustomHeadParams = FALSE;
    }
    else
    {
        _useCustomHeadParams = TRUE;
        
        _headParams = [NSMutableDictionary dictionaryWithDictionary:headParams];
        [_headParams retain];
    }
}

- (void) addHeadParam:(id)key value:value
{
    if(!_headParams)
    {
        _headParams = STRONG_OBJECT(NSMutableDictionary, init);
    }
    
    [_headParams setObject:value forKey:key];
}

- (void) addOption:(NSString*) name value:(id)value
{
    [_options setObject:value forKey:name];
}

- (id) option:(NSString *)name
{
    return [_options objectForKey:name];
}

- (void) setDelegatorID:(DotCDelegatorID)delegatorID
{
    [_options setObject:delegatorID forKey:@"delegatorID"];
}

- (DotCDelegatorID) delegatorID
{
    return [_options objectForKey:@"delegatorID"];
}

- (void) turnOn:(NSString*) name
{
    [self addOption:name value:@"yes"];
}

- (void) turnOff:(NSString*) name
{
    [_options removeObjectForKey:name];
}

- (BOOL) isTurnOn:(NSString*) name
{
    return [@"yes" isEqualToString:[self option:name]];
}

+ (NSDictionary*) defaultHeadParams
{
    return [DOTC_DELEGATE.runtimeConfig getDictionary:@"HEADER_FIELDS"];
}

+ (instancetype) optionFromService:(NSString*)service
{
    return [self optionFromService:service parameters:nil];
}

+ (instancetype) optionFromService:(NSString*)service body:(id)body
{
    return [self optionFromService:service parameters:nil body:body];
}

+ (instancetype) optionFromService:(NSString*)service parameters:(NSDictionary*)parameters
{
    return [self optionFromService:service parameters:parameters body:nil];
}

+ (instancetype) optionFromService:(NSString*)service parameters:(NSDictionary*)parameters body:(id)body
{
    DotCServerRequestOption* ret = WEAK_OBJECT(self, init);
    ret.service = service;
    if(parameters)
    {
        ret.parameters = parameters;
    }
    
    if(body)
    {
        if([body isKindOfClass:[UIImage class]])
        {
            UIImage* image = (UIImage*)body;
            
            id body = UIImageJPEGRepresentation(image, 0.85);
            if(!body)
            {
                body = UIImagePNGRepresentation(image);
            }
            if(!body)
            {
                body = @"";
            }
        }
        
        ret.body = body;
        ret.requestType = REQUEST_POST;
    }
    
    return ret;
}

@end

@interface DotCNetService()
{
    DotCNetCacher*                      _cacher;
    DotCServerRequestManager*           _requestManager;
    NSMutableDictionary*            _requestingOperations;
    NSMutableDictionary*            _requestingUrls;
    
    NSMutableDictionary*            _delegators;
    
    DotCReachability*               _netReachability;
    ENetStatus                      _netStatus;
}

@end

@implementation DotCNetService

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _cacher     = STRONG_OBJECT(DotCNetCacher, init);
    //[_cacher clearAll];
    
    _requestManager = STRONG_OBJECT(DotCServerRequestManager, initWithService:self);
    _requestingOperations = STRONG_OBJECT(NSMutableDictionary, init);
    _requestingUrls = STRONG_OBJECT(NSMutableDictionary, init);
    
    _delegators = STRONG_OBJECT(NSMutableDictionary, init);
    
    _netStatus = NET_STATUS_UNKNOWN;
    
    [self onAppVersionChanged:nil];
    
    [DOTC_DELEGATE on:DOTC_EVENT_VERSION_CHANGED object:self selector:@selector(onAppVersionChanged:)];
    
    return self;
}

- (void) dealloc
{
    [_cacher release];
    [_requestManager release];
    [_requestingOperations release];
    [_requestingUrls release];
    
    [_delegators release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_netReachability stopNotifier];
    [_netReachability release];
    _netReachability = nil;
    
    [super dealloc];
}

- (void) onAppVersionChanged:(DotCDelegatorArguments*)arguments
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_netReachability stopNotifier];
    [_netReachability release];
    _netReachability = nil;
    
    _netReachability = [DotCReachability reachabilityWithHostname:[DOTC_DELEGATE.versionConfig getString:@"NET_STATUS_DETECT_HOST"]];
    [_netReachability retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(netReachabilityChanged:)
                                                 name:kReachabilityChangedNotificationDotC
                                               object:nil];
    
    [_netReachability startNotifier];
    
    _netStatus = reachStatus2NetStataus(_netReachability.currentReachabilityStatus);
}

- (void) netReachabilityChanged:(NSNotification*)notification
{
    DotCReachability * reach = [notification object];
    
    ENetStatus oldStatus = _netStatus;
    
    _netStatus = reachStatus2NetStataus(reach.currentReachabilityStatus);
    
    if(_netStatus == NET_STATUS_UNKNOWN || _netStatus == oldStatus)
    {
        return ;
    }
    
    DotCDelegatorArguments* arguments = [DotCDelegatorArguments argumentsFrom:NET_EVENT_ARGUMENT_NET_STATUS     arg0:@(_netStatus)
                                                                name1:NET_EVENT_ARGUMENT_NET_OLD_STATUS arg1:@(oldStatus)];
    
    [self fire:NET_EVENT_NET_STATUS_CHANGE arguments:arguments];
}

- (ENetStatus) netStatus
{
    return _netStatus;
}

- (NSDictionary*) delegators
{
    return _delegators;
}

- (BOOL) operationRequesting:(NSString*)operation forModule:(NSString*)module
{
    return [_requestingOperations objectForKey:operation2key(operation, module)] != nil;
}

- (void) registeRequestingOperation:(DotCServerRequest*) request
{
    APP_ASSERT(![self operationRequesting:request.operation forModule:request.module]);
    APP_ASSERT(![request.option option:@"____or"]);
    
    [_requestingOperations setObject:request forKey:operation2key(request.operation, request.module)];
}

- (void) removeRequestingOperation:(DotCServerRequest*) request
{
    if([request.option option:@"____or"])
    {
        return ;
    }
    
    [_requestingOperations removeObjectForKey:operation2key(request.operation, request.module)];
    
    [request.option addOption:@"____or" value:@"true"];
}

- (void) cancelOperationIfRequesting:(NSString*) operation forModule:(NSString*)module
{
    NSString* key = operation2key(operation, module);
    DotCServerRequest* request = [_requestingOperations objectForKey:key];
    if(request)
    {
        [_requestManager cancelRequest:request];
        [_requestingOperations removeObjectForKey:key];
        
        [request.option addOption:@"____or" value:@"true"];
    }
}

- (BOOL) urlRequesting:(NSString*)url
{
    return [_requestingUrls objectForKey:url2key(url)] != nil;
}

- (void) registeRequestingUrl:(DotCServerRequest*) request
{
    APP_ASSERT(![self urlRequesting:request.option.url]);
    APP_ASSERT(![request.option option:@"____ur"]);
    
    [_requestingUrls setObject:request forKey:url2key(request.option.url)];
}

- (void) removeRequestingUrl:(DotCServerRequest*) request
{
    if([request.option option:@"____ur"])
    {
        return ;
    }
    
    [_requestingUrls removeObjectForKey:url2key(request.option.url)];
    [request.option addOption:@"____ur" value:@"true"];
}

- (void) cancelUrlIfRequesting:(NSString*)url
{
    NSString* key = url2key(url);
    DotCServerRequest* request = [_requestingUrls objectForKey:key];
    if(request)
    {
        [_requestManager cancelRequest:request];
        [_requestingUrls removeObjectForKey:key];
        
        [request.option addOption:@"____ur" value:@"true"];
    }
}

- (void) requestHandler:(DotCServerRequest*)request responseObject:(id)responseObject error:(NSError*)error
{
    request.error = error;
    
    DotCDelegatorArguments* arguments = WEAK_OBJECT(DotCDelegatorArguments, init);
    
    [arguments setArgument:request.operation for:NET_ARGUMENT_OPERATION];
    [arguments setArgument:request.module    for:NET_ARGUMENT_MODULE];
    [arguments setArgument:request.option    for:NET_ARGUMENT_OPTION];
    [arguments setArgument:request           for:NET_ARGUMENT_REQUEST];
    
    if(responseObject)
    {
        [arguments setArgument:responseObject for:NET_ARGUMENT_RETOBJECT];
    }
    if(error)
    {
        [arguments setArgument:error for:NET_ARGUMENT_ERROR];
    }
    
    DotCServerRequestOption* option = request.option;
    
    if([option isTurnOn:OPTION_NEED_DEBUG_INFO])
    {
        [request dumpDebugInfo];
    }
    
    if([option isTurnOn:OPTION_NEED_LOADING_INDICATOR])
    {
        [DotCHUDUtil decNetLoading];
    }
    
    if([option isTurnOn:OPTION_CHECK_OPERATION_DUPLICATION])
    {
        [self removeRequestingOperation:request];
    }
    
    if([option isTurnOn:OPTION_CHECK_URL_DUPLICATION])
    {
        [self removeRequestingUrl:request];
    }
    
    if(error)
    {
        if([DOTC_DELEGATE.versionConfig getBool:@"DEBUG"])
        {
            if(request.isClientError)
            {
                [DotCHUDUtil showErrorWithStatus:[NSString stringWithFormat:@"Error %ld [%@ %@]", (long)request.httpStatusCode, request.module, request.operation]];
            }
            else if(request.isServerError)
            {
                [DotCHUDUtil showErrorWithStatus:[NSString stringWithFormat:@"Server Error %ld [%@ %@]", (long)request.httpStatusCode, request.module, request.operation]];
            }
            else if(!request.isCancelled)
            {
                [DotCHUDUtil showErrorWithStatus:[NSString stringWithFormat:@"Unknown Error %ld [%@ %@]", (long)request.httpStatusCode, request.module, request.operation]];
            }
        }
        else
        {
            if(request.isServerError)
            {
                [DotCHUDUtil showErrorWithStatus:[NSString stringWithFormat:@"服务器内部错误 [%ld]", (long)request.httpStatusCode]];
            }
        }
    }
    else
    {
        if([option isTurnOn:OPTION_NEED_CACHE] || [option isTurnOn:OPTION_NEED_CACHE_UPDATE])
        {
            [_cacher save:option.url data:responseObject];
        }
    }
    
    [self dispatchRequest:request arguments:arguments];
}

- (void) cacheRequestDispatch:(CachedRequest*) request
{
    [request autorelease];
    
    [self requestHandler:request responseObject:request.responseObject error:nil];
}

- (DotCServerRequest*) doCacheRequest:(NSString*)url data:(id)data
{
    CachedRequest* request = [CachedRequest requestFromUrl:url cacheData:data];
    [request retain];
    [request setUserData:@"yes" key:@"fromCache"];
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [self cacheRequestDispatch:request];
    });
    
    return request;
}

- (DotCServerRequest*) doCacheUpdateRequest:(NSString*)url data:(id)data request:(DotCServerRequest*)originRequest
{
    CachedRequest* request = [CachedRequest requestFromUrl:url cacheData:data];
    [request retain]; // Rlease in cacheRequestDispatch
    
    [request setUserData:@"yes" key:@"fromCacheUpdate"];
    
    DotCServerRequestOption* option = [originRequest.option copy];  // Can't dispatch the request with the old option, because the old option is owned by originRequest
    [option autorelease];
    
    // Turn off all the options, cache update request can't affect the effect maked by origin request
    [option turnOff:OPTION_CHECK_OPERATION_DUPLICATION];
    [option turnOff:OPTION_CHECK_URL_DUPLICATION];
    [option turnOff:OPTION_NEED_LOADING_INDICATOR];
    [option turnOff:OPTION_NEED_CACHE_UPDATE];
    
    [request setOption:option];
    [request setOperation:originRequest.operation module:originRequest.module];

    dispatch_async(dispatch_get_main_queue(),
    ^{
        [self cacheRequestDispatch:request];
    });
    
    return request;
}

- (DotCServerRequest*) doRequest:(NSString*) operation forModule:(NSString*) module withOption:(DotCServerRequestOption*) option
{
    static DotCDelegatorArguments* arguments = nil;
    if(!arguments)
    {
        arguments = STRONG_OBJECT(DotCDelegatorArguments, init);
    }
    
    [arguments setArgument:module for:NET_ARGUMENT_MODULE];
    [arguments setArgument:operation for:NET_ARGUMENT_OPERATION];
    [arguments setArgument:option for:NET_ARGUMENT_OPTION];
    
    [self fire:NET_EVENT_REQUEST arguments:arguments];
    
    if([option isTurnOn:OPTION_REQUEST_FILTERED] && ![option isTurnOn:OPTION_REQUEST_NEVER_FILTERED])
    {
        return nil;
    }
    
    NSString*     url     = option.url;
    
    BOOL checkOperationDuplication = [option isTurnOn:OPTION_CHECK_OPERATION_DUPLICATION];
    BOOL needOperationRegiste = FALSE;
    
    BOOL checkUrlDuplication = [option isTurnOn:OPTION_CHECK_URL_DUPLICATION];
    BOOL needUrlRegiste = FALSE;
    
    assert((checkOperationDuplication&&checkUrlDuplication) == FALSE && "Can't set both OPTION_CHECK_OPERATION_DUPLICATION and OPTION_CHECK_URL_DUPLICATION");
    
    BOOL needCache        = [option isTurnOn:OPTION_NEED_CACHE];
    BOOL needLoadingView  = [option isTurnOn:OPTION_NEED_LOADING_INDICATOR];
    BOOL needCacheUpdate  = [option isTurnOn:OPTION_NEED_CACHE_UPDATE];
    
    assert((needCache&&needCacheUpdate) == FALSE && "Can't set both OPTION_NEED_CACHE and OPTION_NEED_CACHE_UPDATE");  // 
    
    if(needLoadingView)
    {
        [DotCHUDUtil incNetLoading];
    }
    
    if(checkOperationDuplication)
    {
        [self cancelOperationIfRequesting:operation forModule:module];
    }
    
    if(checkUrlDuplication)
    {
        [self cancelUrlIfRequesting:url];
    }
    
    DotCServerRequest*  request = nil;
    
#if defined APP_DEBUG
    if([DOTC_DEBUG_MANAGER isMockRequest:operation module:module option:option])
    {
        request = [DOTC_DEBUG_MANAGER doMockRequest:operation module:module option:option];
    }
#endif
    
    if(!request && needCache)   // No Debug then do cache work
    {
        id data = [_cacher cacheData:url];
        if(data)
        {
            request = [self doCacheRequest:url data:data];
        }
    }
    
    if(!request) // No debug, no cache
    {
        request = [_requestManager request:url option:option];
        
        needOperationRegiste = checkOperationDuplication && TRUE; // Only the request to server need registe
        needUrlRegiste       = checkUrlDuplication && TRUE;       // Only the request to server need registe
     }
    
    [request setOption:option];
    [request setOperation:operation module:module];
    
    if(needOperationRegiste)
    {
        [self registeRequestingOperation:request];
    }
    else if(checkOperationDuplication)
    {
        [request.option turnOff:OPTION_CHECK_OPERATION_DUPLICATION];
    }
    
    if(needUrlRegiste)
    {
        [self registeRequestingUrl:request];
    }
    else if(checkUrlDuplication)
    {
        [request.option turnOff:OPTION_CHECK_URL_DUPLICATION];
    }
    
    if(needCacheUpdate) // Do the cache update first
    {
        id data = [_cacher cacheData:url];
        if(data)
        {
            [self doCacheUpdateRequest:url data:data request:request];   // Dispatch the cache data
        }
    }
    
    // No cache opertion on request from caching
    if([request userData:@"fromCache"])
    {
        [request.option turnOff:OPTION_NEED_CACHE];
    }
    
    return request;
}

- (NSDictionary*) httpCookiesForNSURL:(NSURL*)url
{
    NSMutableDictionary* cookiePairs = WEAK_OBJECT(NSMutableDictionary, init);
    
    // Add self cookies
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    for(NSHTTPCookie* cookie in cookies)
    {
        [cookiePairs setObject:cookie.value forKey:cookie.name];
    }
    
    // Add global cookies(From main server)
    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[DOTC_DELEGATE.versionConfig getString:@"SERVER"]]];
    for(NSHTTPCookie* cookie in cookies)
    {
        // Avoid over-write self cookie
        if(![cookiePairs objectForKey:cookie.name])
        {
            [cookiePairs setObject:cookie.value forKey:cookie.name];
        }
        else
        {
            NSLog(@"Warning : Global cookie %@ conflict and will be ignored", cookie.name);
        }
    }
    
    return cookiePairs;
}

- (NSDictionary*) httpCookiesForURL:(NSString*)url
{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* nsURL = [NSURL URLWithString:url];
    
    return [self httpCookiesForNSURL:nsURL];
}

- (NSString*) cookieStringForURL:(NSString*)url
{
    NSDictionary* cookiePairs = [self httpCookiesForURL:url];
    if(cookiePairs.count)
    {
        NSMutableString* value = WEAK_OBJECT(NSMutableString, init);
        for(NSString* key in cookiePairs.allKeys)
        {
            [value appendFormat:value.length ? @";%@=%@" : @"%@=%@", key, [cookiePairs valueForKey:key]];
        }
        
        return value;
    }

    return nil;
}

- (NSString*) cookieStringForNSURL:(NSURL*)url
{
    NSDictionary* cookiePairs = [self httpCookiesForNSURL:url];
    if(cookiePairs.count)
    {
        NSMutableString* value = WEAK_OBJECT(NSMutableString, init);
        for(NSString* key in cookiePairs.allKeys)
        {
            [value appendFormat:value.length ? @";%@=%@" : @"%@=%@", key, [cookiePairs valueForKey:key]];
        }
        
        return value;
    }
    
    return nil;
}

- (void) clearCache:(float)daysAgo
{
    [_cacher clearCache:daysAgo];
}

- (int) getCacheSize
{
    return [_cacher getCacheSize];
}

+ (instancetype) instance
{
    static DotCNetService* s_instance = nil;
    if(!s_instance)
    {
        s_instance = STRONG_OBJECT(self, init);
    }
    
    return s_instance;
}

@end
