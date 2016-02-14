//
//  NetService.h

//
//  Created by Yang G on 14-5-15.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCDelegatorManager.h"
#import "DotCServerRequest.h"
#import "DotCEventEmitter.h"

typedef enum
{
    REQUEST_NULL = 0,
    REQUEST_GET,
    REQUEST_POST,
} ERequestType;

// Net delegator arguments keys
extern NSString* NET_ARGUMENT_OPERATION;
extern NSString* NET_ARGUMENT_MODULE;
extern NSString* NET_ARGUMENT_OPTION;
extern NSString* NET_ARGUMENT_REQUEST;
extern NSString* NET_ARGUMENT_RETOBJECT;
extern NSString* NET_ARGUMENT_ERROR;

// Net options
extern NSString* OPTION_CHECK_OPERATION_DUPLICATION;
extern NSString* OPTION_CHECK_URL_DUPLICATION;
extern NSString* OPTION_NEED_CACHE;
extern NSString* OPTION_NEED_HANDLE_ERROR;
extern NSString* OPTION_NEED_LOADING_INDICATOR;
extern NSString* OPTION_NEED_CACHE_UPDATE;
extern NSString* OPTION_NEED_DEBUG_INFO;
extern NSString* OPTION_REQUEST_NEVER_FILTERED;
extern NSString* OPTION_REQUEST_FILTERED;

// Net Event Emitter
extern NSString* NET_EVENT_RESPONSE;
// Arguments

extern NSString* NET_ARGUMENT_OPERATION;
extern NSString* NET_ARGUMENT_MODULE;
extern NSString* NET_ARGUMENT_OPTION;
extern NSString* NET_ARGUMENT_REQUEST;
extern NSString* NET_ARGUMENT_RETOBJECT;
extern NSString* NET_ARGUMENT_ERROR;

extern NSString* NET_EVENT_REQUEST;

extern NSString* NET_EVENT_NET_STATUS_CHANGE;
extern NSString* NET_EVENT_ARGUMENT_NET_STATUS;
extern NSString* NET_EVENT_ARGUMENT_NET_OLD_STATUS;
typedef enum
{
    NET_STATUS_UNKNOWN = -1,
    NET_STATUS_DOWN = 0,
    NET_STATUS_WWAN,
    NET_STATUS_WIFI
}ENetStatus;

@interface DotCServerRequestOption : NSObject<NSCopying>

@property (nonatomic, assign) ERequestType              requestType;

- (instancetype) init;
- (void) dealloc;
- (instancetype) copyWithZone:(NSZone *)zone;

- (BOOL) isGet;
- (BOOL) isPost;
- (NSDictionary*) headParams;
- (void) setHeadParams:(NSDictionary*) headParams;
- (void) addHeadParam:(NSString*)key value:(NSString*)value;

- (void) setServer:(NSString*)server;
- (NSString*) server;
- (void) setService:(NSString*)service;
- (NSString*) service;
- (void) setParameters:(NSDictionary*)parameters;
- (NSDictionary*) parameters;

- (NSString*) url;  // Full url

- (float) timeoutInterval;
- (void) setTimeoutInterval:(float)time;

- (void) setDelegatorID:(DotCDelegatorID)delegatorID;
- (DotCDelegatorID) delegatorID;
- (void) setBody:(id)body;
- (id) body;

- (void) addOption:(NSString*) name value:(id)value;
- (id)   option:(NSString*) name;

- (BOOL) isTurnOn:(NSString*) name;
- (void) turnOn:(NSString*) name;
- (void) turnOff:(NSString*) name;
 
+ (instancetype) optionFromService:(NSString*)service;
+ (instancetype) optionFromService:(NSString*)service body:(id)body;
+ (instancetype) optionFromService:(NSString*)service parameters:(NSDictionary*)parameters;
+ (instancetype) optionFromService:(NSString*)service parameters:(NSDictionary*)parameters body:(id)body;
@end

@class DotCNetCacher;
@class ServerRequestDispatcher;
@class DotCServerRequestManager;

@interface DotCNetService : DotCEventEmitter

- (DotCServerRequest*) doRequest:(NSString*)operation forModule:(NSString*)module withOption:(DotCServerRequestOption*)option;
- (ENetStatus) netStatus;

- (void) clearCache:(float)daysAgo;
- (int) getCacheSize;

+ (instancetype) instance;

@end

#define DOTC_NET_SERVICE [DotCNetService instance]



