//
//  AlertUtil.h
//  DotC
//
//  Created by Yang G on 14-9-30.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* ALERT_ARGUMENT_NAME;
extern NSString* ALERT_ARGUMENT_BUTTON_NAME;
extern NSString* ALERT_ARGUMENT_USERDATA;

@class DotCDelegatorArguments;

typedef void (^ AlertViewDelegatorBlock)(DotCDelegatorArguments* arg);

#define ALERT_DELEGATOR_BLOCK(blockCode) __alertViewDelegatorBlock(^ void (DotCDelegatorArguments* args)blockCode)

AlertViewDelegatorBlock __alertViewDelegatorBlock(AlertViewDelegatorBlock block);

@interface DotCAlertUtil : NSObject

+ (void) showAlert:(NSString*)title message:(NSString*)message;

+ (void) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator;

+ (void) showAlert:(NSString*)title message:(NSString*)message delegator:(id)delegator userData:(id)userData;

+ (void) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons;

+ (void) showAlert:(NSString*)title message:(NSString*)message buttons:(NSArray*)buttons userData:(id)userData;

@end

