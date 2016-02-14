//
//  DotCUIManager.m
//  LibDotC
//
//  Created by Yang G on 14-10-20.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCUIManager.h"
#import "DotCMainWindow.h"
#import "DotCImageUtil.h"
#import "DotCImageView.h"

@interface DotCUIManager()
{
    UINavigationController*     _mainNavigationController;
    UIWindow*                   _mainWindow;
}

@end

@implementation DotCUIManager

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return nil;
    }
    
    // Create window
    _mainWindow = WEAK_OBJECT(DotCMainWindow, initWithFrame:[[UIScreen mainScreen] bounds]);
    [_mainWindow retain];
    
    // Create navigationController
    _mainNavigationController = (UINavigationController*)_mainWindow.rootViewController;
    [_mainNavigationController retain];
    
    // Setup UI face
    {
        NSString* name = [DOTC_GLOBAL_CONFIG getString:@"UI.DEFAULT_NAVIGATION_BAR_IMAGE"];
        UIImage* image = [DotCImageUtil getImage:name];
        [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    [_mainWindow makeKeyAndVisible];
    
    return self;
}

- (UIWindow*) mainWindow
{
    return _mainWindow;
}

- (UINavigationController*) mainNavigationController
{
    return _mainNavigationController;
}

- (DotCViewController*) startWithClass:(Class)controllerClass animated:(BOOL)animated
{
    if(![controllerClass isSubclassOfClass:[DotCViewController class]])
    {
        return nil;
    }
    
    DotCViewController* controller = WEAK_OBJECT(controllerClass, init);
    
    return [self startWithController:controller animated:animated];
}

- (DotCViewController*) startWithController:(DotCViewController*)controller animated:(BOOL)animated
{
    if(controller)
    {
        [_mainNavigationController setViewControllers:@[controller] animated:animated];
    }
    
    return controller;
}

+ (instancetype) instance
{
    static DotCUIManager* s_instance = nil;
    APP_DISPATCH_ONCE(^(void){if(s_instance == nil){s_instance = STRONG_OBJECT(self, init);}});
    
    return s_instance;
}

@end
