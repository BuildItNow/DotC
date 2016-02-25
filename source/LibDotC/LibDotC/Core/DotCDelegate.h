//
//  DotCDelegate.h
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//
@class DotCJSONConfig;
@class DotCWDictionaryWrapper;
@class DotCWPDictionaryWrapper;

extern NSString*    DOTC_EVENT_VERSION_CHANGED;

DOTC_DECL_DELEGATOR_FEATURE_CLASS(__DFCAppDelegate, UIResponder);

@interface DotCDelegate : __DFCAppDelegate<UIApplicationDelegate>

@property (retain, nonatomic) UIWindow*     window;
@property (copy, nonatomic) NSString*       appVersion;
@property (nonatomic, readonly) DotCJSONConfig*          versionConfig;
@property (nonatomic, readonly) DotCWDictionaryWrapper*  runtimeConfig;
@property (nonatomic, readonly) DotCWPDictionaryWrapper* persistConfig;

@property (nonatomic, readonly) BOOL isInstall; // Install app, Note. Not update app

- (void) on:(NSString*)event object:(id)object selector:(SEL)selector;
- (void) once:(NSString*)event object:(id)object selector:(SEL)selector;
- (void) remove:(NSString*)event object:(id)object selector:(SEL)selector;
- (void) fire:(NSString*)event arguments:(DotCDelegatorArguments*)arguments;

- (void) clearCache:(float)daysAgo;
- (int)  getCacheSize;
@end

#define DOTC_APPLICATION [UIApplication sharedApplication]
#define DOTC_DELEGATE ((DotCDelegate*)[DOTC_APPLICATION delegate])
