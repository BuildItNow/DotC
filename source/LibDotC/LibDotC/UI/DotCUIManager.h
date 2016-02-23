//
//  DotCUIManager.h
//  LibDotC
//
//  Created by Yang G on 14-10-20.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

@class DotCViewController;

@interface DotCUIManager : NSObject

- (UIWindow*) mainWindow;

- (UINavigationController*) mainNavigationController;

- (DotCViewController*) startWithClass:(Class)controllerClass animated:(BOOL)animated;
- (DotCViewController*) startWithController:(DotCViewController*)controller animated:(BOOL)animated;

+ (instancetype) instance;

@end

#define DOTC_UI_MANAGER [DotCUIManager instance]
