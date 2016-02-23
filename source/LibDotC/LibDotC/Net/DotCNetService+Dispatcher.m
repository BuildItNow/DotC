//
//  ServerRequestDispatcher.m

//
//  Created by Yang G on 14-5-16.
//  Copyright (c) 2014年 .C . All rights reserved.
//


#import "DotCNetService+Dispatcher.h"
#import "DotCServerRequest.h"
#import "DotCNetCacher.h"

@implementation DotCNetService (Dispatcher)

#warning "Need add module support"
- (void) dispatchRequest:(DotCServerRequest*)request arguments:(DotCDelegatorArguments*)arguments
{
    if(!request.isCancelled && [request userData:@"fromServer"])
    {
        [self fire:NET_EVENT_RESPONSE arguments:arguments];
    }
    
    DotCServerRequestOption* option = request.option;
    APP_ASSERT(option);
    
    if(request.error && ![option isTurnOn:OPTION_NEED_HANDLE_ERROR])
    {
        return ;
    }
    
    // 1: Do the root dispatch, if the root dispatching returns TRUE, then finish this operation. or dispatch to module
//    {
//        DotCDelegator* delegator = [self getDelegator:request.operation module:request.module];
//        if(delegator && [delegator perform:arguments])
//        {
//            [request setUserData:@"dispatcher" key:@"handledBy"];
//            
//            return ;
//        }
//
//    }
//    
//    // 2: Do the module dispatch, if the module returns TRUE, then finish this operation. or dispatch to request self delegator.
//    {
//        id module = [MODULE_MANAGER module:request.module];
//        if(module && [module handleRequest:request arguments:arguments])
//        {
//            [request setUserData:@"module" key:@"handledBy"];
//            
//            return ;
//        }
//    }
    
    // 3: Dispatch to request self delegator
    DotCDelegatorID delegatorID = option.delegatorID;
    if(delegatorID)
    {
        [DOTC_GLOBAL_DELEGATOR_MANAGER performDelegator:delegatorID arguments:arguments];
        
        [request setUserData:@"requestSelf" key:@"handledBy"];
        
        return ;
    }
}

//NSString* generateDelegatorKey(NSString* operation, NSString* module)
//{
//    return [NSString stringWithFormat:@"%@#%@", module, operation];
//}
//
//- (DotCDelegator*) getDelegator:(NSString*) operation module:(NSString*)module
//{
//    NSString* delegatorKey = generateDelegatorKey(operation, module);
//    
//    return [[self delegators] objectForKey:delegatorKey];
//}
//
//- (void) registeDelegator:(id)subject selector:(SEL) selector forOperation:(NSString*)operation andModule:(NSString*)module
//{
//    NSString* delegatorKey = generateDelegatorKey(operation, module);
//    
//    DotCDelegator* old = [[self delegators] objectForKey:delegatorKey];
//    if(!old)
//    {
//        DotCDelegator* delegator = WEAK_OBJECT(DotCDelegator, init);
//        [delegator setSubject:subject selector:selector];
//        
//        [[self delegators] setObject:delegator forKey:delegatorKey];
//    }
//    else
//    {
//        DotCDelegatorID delegatorID = [DotCDelegator generateDelegatorID:subject selector:selector];
//        
//        if(![delegatorID isEqualToString:old.delegatorID])
//        {
//            NSLog(@"ServerRequestDispatcher registeRequestDelegator %@ will replace %@ in operation %@ at module %@", delegatorID, old.delegatorID, operation, module);
//            
//            DotCDelegator* delegator = WEAK_OBJECT(DotCDelegator, init);
//            [delegator setSubject:subject selector:selector];
//
//            [[self delegators] setObject:delegator forKey:delegatorKey];
//        }
//    }
//}
//
//- (void) removeDelegator:(NSString*)operation forModule:(NSString*)module
//{
//    [[self delegators] removeObjectForKey:generateDelegatorKey(operation, module)];
//}
//
//- (void) registeModuleDelegator:(id)subject selector:(SEL) selector forOperation:(NSString*)operation andModule:(NSString*)module
//{
//    [[MODULE_MANAGER module:module] registeDelegator:subject selector:selector forOperation:operation];
//}
//
//- (void) removeModuleDelegator:(NSString*)operation forModule:(NSString*)module
//{
//    [[MODULE_MANAGER module:module] removeDelegator:module];
//}

@end

