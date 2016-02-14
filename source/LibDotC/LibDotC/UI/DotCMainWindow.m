//
//  MainWindow.m
//  LibDotC
//
//  Created by Yang G on 14-10-20.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCMainWindow.h"

@implementation DotCMainWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    [super setRootViewController:WEAK_OBJECT(UINavigationController, init)];
    
    return self;
}

- (void) setRootViewController:(UIViewController *)rootViewController
{
    // Do nothing, can't change it
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
