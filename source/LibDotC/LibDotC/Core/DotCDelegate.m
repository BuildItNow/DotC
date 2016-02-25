
//
//  DotCDelegate.m
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "DotCDelegate.h"
#import "DotCDebugManager.h"
#import "DotCImageManagerAdapter.h"

NSString*    DOTC_EVENT_VERSION_CHANGED = @"DOTC_EVENT_VERSION_CHANGED";

@interface DotCDelegate()
{
    DotCEventEmitter*       _ee;
}

@end

DOTC_IMPL_DELEGATOR_FEATURE_CLASS(__DFCAppDelegate, UIResponder <UIApplicationDelegate>);

@implementation DotCDelegate

@synthesize appVersion = _appVersion, versionConfig = _versionConfig, runtimeConfig = _runtimeConfig, persistConfig = _persistConfig;
@synthesize isInstall = _isInstall;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    srand([[NSDate date] timeIntervalSince1970]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    // Load config
    DotCJSONConfig* configs = DOTC_GLOBAL_CONFIG;
    
    // Run time config
    DotCDictionaryWrapper* runtimeConfig = self.runtimeConfig;
    
    // Persist config
    DotCDictionaryWrapper* persistConfig =self.persistConfig;
    
    if(!_appVersion)
    {
        self.appVersion = @"RELEASE";
    }
    
    // Setup UI
    DotCUIManager* uiManager = DOTC_UI_MANAGER;
    
    // Net service
    DotCNetService* netService = DOTC_NET_SERVICE;
    
    // Net Image manager
    [DotCImageManager setIntegrateAdapter:[DotCImageManagerAdapter instance]];
    
    DotCImageManager* imageManager = DOTC_IMAGE_MANAGER;
    
    // Debug part
    DotCDebugManager* debugManager = DOTC_DEBUG_MANAGER;
    
    // For old app
#warning old app compatible
    _isInstall = FALSE;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"first"])   // Update
    {
        
    }
    else
    {
        if(![self.persistConfig getString:@"installed"])
        {
            _isInstall = TRUE;
            
            [self.persistConfig set:@"installed" value:@"TRUE"];
        }
    }
    
    return YES;
}

- (DotCWDictionaryWrapper*) runtimeConfig
{
    if(!_runtimeConfig)
    {
        _runtimeConfig = STRONG_OBJECT(DotCWDictionaryWrapper, init);
    }
    
    return _runtimeConfig;
}

- (DotCWPDictionaryWrapper*) persistConfig
{
    if(!_persistConfig)
    {
        _persistConfig = [DotCWPDictionaryWrapper wrapperFromName:@"__PERSIST_CONFIG"];
        [_persistConfig retain];
    }
    
    return _persistConfig;
}

- (void) setWindow:(UIWindow *)window
{
    // Do nothing
}

- (UIWindow*) window
{
    return DOTC_UI_MANAGER.mainWindow;
}

- (DotCEventEmitter*) ee
{
    if(!_ee)
    {
        _ee = STRONG_OBJECT(DotCEventEmitter, init);
    }
    
    return _ee;
}

- (void) setAppVersion:(NSString *)version
{
    APP_ASSERT(version);
    
    [_appVersion release];
    _appVersion = [version copy];
    
    [_versionConfig release];
    
    _versionConfig = [DOTC_GLOBAL_CONFIG getSubConfig:_appVersion];
    [_versionConfig retain];
    
    [self fire:DOTC_EVENT_VERSION_CHANGED arguments:WEAK_OBJECT(DotCDelegatorArguments, init)];
}

- (void) on:(NSString*)event object:(id)object selector:(SEL)selector
{
    [self.ee on:event object:object selector:selector];
}

- (void) once:(NSString*)event object:(id)object selector:(SEL)selector
{
    [self.ee once:event object:object selector:selector];
}

- (void) remove:(NSString*)event object:(id)object selector:(SEL)selector
{
    [self.ee remove:event object:object selector:selector];
}

- (void) fire:(NSString*)event arguments:(DotCDelegatorArguments*)arguments
{
    [self.ee fire:event arguments:arguments];
}

- (void) clearCache:(float)daysAgo
{
    [DOTC_NET_SERVICE clearCache:daysAgo];
    [DOTC_IMAGE_MANAGER clearCache:daysAgo];
}

- (int)  getCacheSize
{
    int ret = [DOTC_NET_SERVICE getCacheSize];
    ret += [DOTC_IMAGE_MANAGER getCacheSize];
    
    return ret;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
