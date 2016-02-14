//
//  DotCViewController.m
//  LibDotC
//
//  Created by Yang G on 14-10-20.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCViewController.h"
#import "DotCSystemUtil.h"

DOTC_IMPL_DELEGATOR_FEATURE_CLASS(__DotCViewController, UIViewController)

@interface DotCViewController()
{
    NSTimeInterval       _stayInTime;
}
@end

@implementation DotCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([DotCSystemUtil aboveIOS7_0])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

@end
