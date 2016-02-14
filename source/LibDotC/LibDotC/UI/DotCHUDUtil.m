//
//  HUDUtil.m
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "DotCHUDUtil.h"
#import "SVProgressHUD.h"

@interface NetLoadingIndicator : NSObject
{
    UIActivityIndicatorView*    _view;
    int                         _counter;
}

- (void) incNetLoading;
- (void) decNetLoading;

@end

@implementation NetLoadingIndicator

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _view = STRONG_OBJECT(UIActivityIndicatorView, initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge);
    _view.color = [UIColor grayColor];
    
    _counter = 0;
    
    return self;
}

- (void) dealloc
{
    [_view release];
    
    [super dealloc];
}

- (void) incNetLoading
{
    ++_counter;

    if(_counter == 1)
    {
        [DOTC_DELEGATE.window addSubview:_view];
        _view.frame = DOTC_DELEGATE.window.frame;
        _view.center = DOTC_DELEGATE.window.center;
        
        [_view startAnimating];
    }
}

- (void) decNetLoading
{
    --_counter;
    
    APP_ASSERT(_counter >= 0);
    if(_counter == 0)
    {
        [_view stopAnimating];
        [_view removeFromSuperview];
    }
    
    _counter = MAX(0, _counter);
}
@end

static NetLoadingIndicator* netLodingIndicator()
{
    static NetLoadingIndicator* s_instance = nil;
    if(!s_instance)
    {
        s_instance = STRONG_OBJECT(NetLoadingIndicator, init);
    }
    
    return s_instance;
}

@implementation DotCHUDUtil

+ (void) incNetLoading
{
    [netLodingIndicator() incNetLoading];
}

+ (void) decNetLoading
{
    [netLodingIndicator() decNetLoading];
}

+ (void)show
{
    [SVProgressHUD show];
}

+ (void)showWithMaskType:(HUDMaskType)maskType
{
    [SVProgressHUD showWithMaskType:maskType];
}

+ (void)showWithStatus:(NSString*)status
{
    [SVProgressHUD showWithStatus:status];
}

+ (void)showWithStatus:(NSString*)status maskType:(HUDMaskType)maskType
{
    [SVProgressHUD showWithStatus:status maskType:maskType];
}

+ (void)showSuccessWithStatus:(NSString*)string
{
    [SVProgressHUD showSuccessWithStatus:string];
}

+ (void)showErrorWithStatus:(NSString *)string
{
    [SVProgressHUD showErrorWithStatus:string];
}

+ (void)showImage:(UIImage*)image status:(NSString*)status
{
    [SVProgressHUD showImage:image status:status];
}

+ (void)dismiss
{
    [SVProgressHUD dismiss];
}

@end



