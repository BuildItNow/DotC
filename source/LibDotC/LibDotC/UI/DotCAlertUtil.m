//
//  AlertUtil.m
//  DotC
//
//  Created by Yang G on 14-9-30.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCAlertUtil.h"

@interface AlertController : NSObject

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message;

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator;

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator userData:(id)userData;

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons;

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons userData:(id)userData;

@end

NSString* ALERT_ARGUMENT_NAME = @"ALERT_ARGUMENT_NAME";
NSString* ALERT_ARGUMENT_BUTTON_NAME = @"ALERT_ARGUMENT_BUTTON_NAME";
NSString* ALERT_ARGUMENT_USERDATA = @"ALERT_ARGUMENT_USERDATA";

typedef void (^ DelegatorBlock)(DotCDelegatorArguments*);

@interface AlertButtonItem : NSObject
{
    NSString*           _name;
    NSString*           _delegatorID;
    DelegatorBlock      _delegatorBlock;
}

- (void) trigger:(NSString*)viewName data:(id)data;

@end

@implementation AlertButtonItem

- (void) dealloc
{
    [_name release];
    [_delegatorID release];
    [_delegatorBlock release];
    
    [super dealloc];
}

- (void) trigger:(NSString*)viewName data:(id)data
{
    if(!_delegatorID && !_delegatorBlock)
    {
        return ;
    }
    
    DotCDelegatorArguments* arg = WEAK_OBJECT(DotCDelegatorArguments, init);
    
    if(viewName)
    {
        [arg setArgument:viewName for:ALERT_ARGUMENT_NAME];
    }
    if(_name)
    {
        [arg setArgument:_name for:ALERT_ARGUMENT_BUTTON_NAME];
    }
    if(data)
    {
        [arg setArgument:data for:ALERT_ARGUMENT_USERDATA];
    }
    
    if(_delegatorID)
    {
        [DOTC_GLOBAL_DELEGATOR_MANAGER performDelegator:_delegatorID arguments:arg];
    }
    else
    {
        _delegatorBlock(arg);
    }
}

+ (instancetype) itemFrom:(NSString*)name delegator:(id)delegator
{
    AlertButtonItem* ret = WEAK_OBJECT(AlertButtonItem, init);
    ret->_name = [name copy];
    
    if([delegator isKindOfClass:[NSString class]])
    {
        ret->_delegatorID = (NSString*)[delegator copy];
    }
    else
    {
        ret->_delegatorBlock = (DelegatorBlock)[delegator copy];
    }
    
    return ret;
}


@end

@interface AlertController()<UIAlertViewDelegate>
{
    UIAlertView*        _alertView;
    id                  _userData;
    NSString*           _name;
    NSMutableArray*     _buttonItems;
}

@end

@implementation AlertController

- (instancetype) initWithName:(NSString*)name userData:(id)userData
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _alertView = WEAK_OBJECT(UIAlertView, init);
    _alertView.delegate = [self retain];
    
    _userData = [userData retain];
    _name     = [name copy];
    _buttonItems = STRONG_OBJECT(NSMutableArray, init);
    
    return self;
}

- (void) dealloc
{
    _alertView.delegate = nil;
    _alertView = nil;
    
    [_userData release];
    [_name release];
    [_buttonItems release];
    
    [super dealloc];
}

- (void) setMessage:(NSString*)message
{
    _alertView.message = message;
}

- (void) setTitle:(NSString*)title
{
    _alertView.title = title;
}

- (void) showAlert
{
    [_alertView show];
}

- (void) setupButtons:(NSArray*)buttons
{
    NSString* buttonName      = nil;
    id        buttonDelegator = nil;
    NSString* buttonTitle     = nil;
    
    for(id item in buttons)
    {
        buttonName      = nil;
        buttonDelegator = nil;
        buttonTitle     = nil;
        
        if([item isKindOfClass:[NSString class]])   // only title
        {
            buttonTitle = (NSString*)item;
        }
        else if([item isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* btnItem = (NSDictionary*)item;
            buttonTitle = [btnItem objectForKey:@"title"];
            buttonName  = [btnItem objectForKey:@"name"];
            buttonDelegator = [btnItem objectForKey:@"delegator"];
        }
        else
        {
            APP_ASSERT(false);
            return ;
        }
        
        [_alertView addButtonWithTitle:buttonTitle];
        [_buttonItems addObject:[AlertButtonItem itemFrom:buttonName delegator:buttonDelegator]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex<0 || buttonIndex>=_buttonItems.count)
    {
        return ;
    }
    
    [_buttonItems[buttonIndex] trigger:_name data:_userData];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _alertView.delegate = nil;
    _alertView = nil;
    
    [self autorelease];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message
{
    return [self showAlert:title message:message viewName:nil delegator:nil userData:nil];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator
{
    return [self showAlert:title message:message viewName:nil delegator:delegator userData:nil];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator userData:(id)userData
{
    return [self showAlert:title message:message viewName:nil delegator:delegator userData:userData];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message viewName:(NSString*)name delegator:(id)delegator
{
    return [self showAlert:title message:message viewName:name delegator:delegator userData:nil];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message viewName:(NSString*)name delegator:(id)delegator userData:(id)userData
{
    AlertController* ret = WEAK_OBJECT(AlertController, initWithName:name userData:userData);
    ret.title    = title;
    ret.message  = message;
    
    delegator = delegator ? delegator : (id)(^(DotCDelegatorArguments* args){});
    [ret setupButtons:@[@{@"title":@"确定", @"delegator":delegator}]];
    
    [ret showAlert];
    
    return ret;
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons
{
    return [self showAlert:title message:message viewName:nil buttons:buttons userData:nil];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons userData:(id)userData
{
    return [self showAlert:title message:message viewName:nil buttons:buttons userData:userData];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message viewName:(NSString*)name buttons:(NSArray*)buttons
{
    return [self showAlert:title message:message viewName:name buttons:buttons userData:nil];
}

+ (instancetype) showAlert:(NSString*)title message:(NSString*)message viewName:(NSString*)name buttons:(NSArray*)buttons userData:(id)userData
{
    AlertController* ret = WEAK_OBJECT(AlertController, initWithName:name userData:userData);
    ret.title    = title;
    ret.message  = message;
    
    [ret setupButtons:buttons];
    
    [ret showAlert];
    
    return ret;
}

@end


AlertViewDelegatorBlock __alertViewDelegatorBlock(AlertViewDelegatorBlock block)
{
    return [[block copy]autorelease];
}

@implementation DotCAlertUtil

+ (void) showAlert:(NSString*)title message:(NSString*)message
{
    [AlertController showAlert:title message:message];
}

+ (void) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator
{
    [AlertController showAlert:title message:message delegator:delegator];
}

+ (void) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator userData:(id)userData
{
    [AlertController showAlert:title message:message delegator:delegator userData:userData];
}

+ (void) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons
{
    [AlertController showAlert:title message:message buttons:buttons];
}

+ (void) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons userData:(id)userData
{
    [AlertController showAlert:title message:message buttons:buttons userData:userData];
}

@end
