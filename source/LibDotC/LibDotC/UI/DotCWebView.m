//
//  WebViewUtil.m
//  LibDotC
//
//  Created by Yang G on 14-11-12.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCWebView.h"
//#import "WebViewInvokersManager.h"

@interface DotCWebView()
{
//    WebViewInvokersManager*     _invokesManager;
}

@end

@implementation DotCWebView

- (instancetype) initWithFrame:(CGRect)frame
{
    if(!(self = [super initWithFrame:frame]))
    {
        return self;
    }
    
    //[self setupJSEngine];
    
    return self;
}

- (void) dealloc
{
//    if(_invokesManager)
//    {
//        [_invokesManager setDelegate:nil];  // clean delegate, avoid [super setDelegate] fail
//    }
    
    //[self deSetupJSEngine];
    
    [super dealloc];
}

//- (void) setupJSEngine
//{
//    if(_invokesManager)
//    {
//        return ;
//    }
//    
//    _invokesManager = STRONG_OBJECT(WebViewInvokersManager, init);
//    [_invokesManager setup:self];
//}
//
//- (void) deSetupJSEngine
//{
//    if(!_invokesManager)
//    {
//        return ;
//    }
//    
//    [_invokesManager deSetup];
//    [_invokesManager release];
//    
//    _invokesManager = nil;
//}

- (id<UIWebViewDelegate>) delegate
{
//    if(_invokesManager)
//    {
//        return (id<UIWebViewDelegate>)[_invokesManager delegate];
//    }
//    else
    {
        return [self concreteDelegate];
    }
}

- (void) setDelegate:(id<UIWebViewDelegate>)delegate
{
//    if(_invokesManager)
//    {
//        [_invokesManager setDelegate:delegate];
//    }
//    else
    {
        [self setConcreteDelegate:delegate];
    }
}

- (void) setConcreteDelegate:(id<UIWebViewDelegate>)delegate
{
    [super setDelegate:delegate];
}

- (id<UIWebViewDelegate>) concreteDelegate
{
    return [super delegate];
}

- (void) loadURL:(NSString*)url
{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* nsURL = [NSURL URLWithString:url];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsURL];
    
    NSDictionary* headerFields = [DOTC_DELEGATE.runtimeConfig getDictionary:@"HEADER_FIELDS"];
    if(headerFields)
    {
        for(NSString* key in headerFields.allKeys)
        {
            [request setValue:[headerFields objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    NSString* cookieValue = [DOTC_NET_SERVICE cookieStringForNSURL:nsURL];
    if(cookieValue.length)
    {
        [request setValue:cookieValue forHTTPHeaderField:@"Cookie"];
    }
    
    [self loadRequest:request];
}
//
//- (void) registeInvoker:(NSString*)name object:(id)object selector:(SEL)selector
//{
//    [_invokesManager registeInvoker:name object:object selector:selector];
//}
//
//- (void) removeInvoker:(NSString*)name
//{
//    [_invokesManager removeInvoker:name];
//}
//
//- (void) removeInvokers:(id)object
//{
//    [_invokesManager removeInvokers:object];
//}

+ (DotCWebView*) viewFrom:(NSString*)url
{
    DotCWebView* view = WEAK_OBJECT(DotCWebView, init);
    
    [view loadURL:url];
    
    return view;
}

+ (DotCWebView*) viewFrom:(NSString*)url frame:(CGRect)frame
{
    DotCWebView* view = [self viewFrom:url];
    view.frame = frame;
    
    return view;
}

@end
