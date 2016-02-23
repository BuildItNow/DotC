//
//  WebViewUtil.h
//  LibDotC
//
//  Created by Yang G on 14-11-12.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCWebView : UIWebView

- (void) loadURL:(NSString*)url;

//- (void) registeInvoker:(NSString*)name object:(id)object selector:(SEL)selector;
//- (void) removeInvoker:(NSString*)name;
//- (void) removeInvokers:(id)object;

+ (DotCWebView*) viewFrom:(NSString*)url;
+ (DotCWebView*) viewFrom:(NSString*)url frame:(CGRect)frame;

@end