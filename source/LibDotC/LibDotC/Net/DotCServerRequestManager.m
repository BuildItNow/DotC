//
//  RequestManager.m
//  DotC
//
//  Created by Yang G on 14-7-4.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "DotCServerRequestManager.h"
#import "DotCServerRequest.h"
#import "JSONKit.h"
#import "DotCSystemUtil.h"
#import "DotCDeviceUtil.h"

@interface DotCImageResponseSerializer : AFImageResponseSerializer
@end


@implementation DotCImageResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error])
    {
        return nil;
    }

    return data;//WEAK_OBJECT(UIImage, initWithData:data);
}

@end

@interface DotCJSONResponseSerializer : AFJSONResponseSerializer
@end


@implementation DotCJSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error])
    {
        return nil;
    }
    
    id ret = [data objectFromJSONData];
    if([ret isKindOfClass:[NSDictionary class]])
    {
        ret = [DotCDictionaryWrapper wrapperFromDictionary:ret];
    }
    
    return ret;
}

@end

@interface DotCXMLResponseSerializer : AFXMLParserResponseSerializer

@end


@implementation DotCXMLResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error])
    {
        return nil;
    }
    
    return [[[NSXMLParser alloc] initWithData:data] autorelease];
}

@end

AFHTTPResponseSerializer* defaultSerializer()
{
    static AFCompoundResponseSerializer* s_serializer = nil;
    if(!s_serializer)
    {
        NSArray* serializers = @[
                                    [DotCJSONResponseSerializer serializer],
                                    [DotCImageResponseSerializer serializer],
                                    //[DotCXMLResponseSerializer serializer]
                                ];
        
        s_serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:serializers];
        [s_serializer retain];
    }
    
    return s_serializer;
}

@interface ServerRequestOperation : AFHTTPRequestOperation
{
    DotCServerRequest* _serverRequest;
}

- (DotCServerRequest*) serverRequest;

@end

@implementation ServerRequestOperation

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest
{
    if(!(self = [super initWithRequest:urlRequest]))
    {
        return self;
    }
    
    _serverRequest = STRONG_OBJECT(DotCServerRequest, init);
    [_serverRequest setupOperation:self];
    
    return self;
}

- (void) dealloc
{
    [_serverRequest deSetupOperation];
    [_serverRequest release];
    
    [super dealloc];
}

- (DotCServerRequest*) serverRequest
{
    return _serverRequest;
}

@end

typedef void (^ SuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^ FailBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface DotCServerRequestManager ()
{
    SuccessBlock _successBlock;
    FailBlock    _failBlock;
    
    DotCNetService*     _service;
    
    DotCServerRequestOption*   _requestOption;
}

@end

@implementation DotCServerRequestManager

- (instancetype)initWithService:(DotCNetService*)service
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _service = service;
    
    __block DotCServerRequestManager* weakSelf = self;
    _successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [weakSelf requestSuccessHandler:(ServerRequestOperation*)operation responseObject:responseObject];
    };
    _successBlock = [_successBlock copy];
    
    _failBlock = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        [weakSelf requestFailHandler:(ServerRequestOperation*)operation error:error];
    };
    _failBlock = [_failBlock copy];
    
    self.responseSerializer = defaultSerializer();
    
    [DOTC_DELEGATE on:DOTC_EVENT_VERSION_CHANGED object:self selector:@selector(onAppVersionChanged:)];
    
    [self onAppVersionChanged:nil];
    
    NSMutableString* userAgent = [NSMutableString stringWithFormat:@"IOS_%@_%@", [DotCSystemUtil iosVersion], [DotCDeviceUtil deviceTypeName]];
    [self.requestSerializer setValue:userAgent  forHTTPHeaderField:@"User-Agent"];
    
    return self;
}

- (void) onAppVersionChanged:(DotCDelegatorArguments*)arguments
{
    DotCDictionaryWrapper* headerFields = [DOTC_DELEGATE.versionConfig getDictionaryWrapper:@"HEADER_FIELDS"];
    for(NSString* key in headerFields.dictionary.allKeys)
    {
        [self.requestSerializer setValue:[headerFields getString:key]  forHTTPHeaderField:key];
    }
    
    float timeoutInterval = [DOTC_DELEGATE.versionConfig getFloat:@"TIME_OUT_INTERVAL"];
    if(timeoutInterval <= 0.0001f)
    {
        timeoutInterval = 30.0f;
    }
    
    self.requestSerializer.timeoutInterval = timeoutInterval;
}

- (void) dealloc
{
    [_successBlock release];
    [_failBlock release];
    
    [super dealloc];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"
- (void) requestSuccessHandler:(ServerRequestOperation*)operation responseObject:(id)responseObject
{
    [operation.serverRequest setUserData:@"yes" key:@"fromServer"];
    [_service requestHandler:operation.serverRequest responseObject:responseObject error:nil];

}

- (void) requestFailHandler:(ServerRequestOperation*)operation error:(NSError*)error
{
    [operation.serverRequest setUserData:@"yes" key:@"fromServer"];
    [_service requestHandler:operation.serverRequest responseObject:nil error:error];
}
#pragma clang diagnostic pop

- (DotCServerRequest*) request:(NSString*)url option:(DotCServerRequestOption*)option
{
    DotCServerRequest* ret = nil;
    
    _requestOption = option;
    if(option.isGet)
    {
        ret = [self GET:url];
    }
    else if(option.isPost)
    {
        ret = [self POST:url];
    }
    _requestOption = nil;
    
    return ret;
}

- (DotCServerRequest*) GET:(NSString*)url
{
    ServerRequestOperation* operation = (ServerRequestOperation*)[self GET:url parameters:nil success:_successBlock failure:_failBlock];
    APP_ASSERT([operation.request isKindOfClass:[NSMutableURLRequest class]]);
    
    return operation.serverRequest;
}

- (DotCServerRequest*) POST:(NSString*)url
{
    id body = _requestOption.body;
    
    typedef void (^ BodyConstructor)(id <AFMultipartFormData> formData);
    BodyConstructor bodyCtor = ^(id <AFMultipartFormData> formData)
    {
        NSData* data = nil;
        if([body isKindOfClass:[NSDictionary class]])
        {
            NSString* json = ((NSDictionary*)body).JSONString;
            data = [json dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if([body isKindOfClass:[NSString class]])
        {
            data = [((NSString*)body) dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if([body isKindOfClass:[NSData class]])
        {
            data = body;
        }
        else
        {
            APP_ASSERT(false && "Non-support body type");
        }
        
        [formData appendPartWithHeaders:nil body:data];
    };
    ServerRequestOperation* operation = (ServerRequestOperation*)[self POST:url parameters:nil constructingBodyWithBlock:bodyCtor success:_successBlock failure:_failBlock];
    APP_ASSERT([operation.request isKindOfClass:[NSMutableURLRequest class]]);
    
    return operation.serverRequest;
}
                
- (void) cancelRequest:(DotCServerRequest*)request
{
    AFHTTPRequestOperation* operation = [request httpOperation];
    if(operation)
    {
        [operation cancel];
    }
}

    
- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary* headerFields = _requestOption.headParams;
    if(headerFields)
    {
        for(NSString* key in headerFields.allKeys)
        {
            [((NSMutableURLRequest*)request) setValue:[headerFields objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    float timeoutInterval = _requestOption.timeoutInterval;
    if(timeoutInterval >= 0.0001f)
    {
        ((NSMutableURLRequest*)request).timeoutInterval = timeoutInterval;
    }

    ServerRequestOperation* operation = WEAK_OBJECT(ServerRequestOperation, initWithRequest:request);
    
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;
    
    return operation;
}

@end
