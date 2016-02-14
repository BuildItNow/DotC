//
//  ServerRequestDispatcher.h

//
//  Created by Yang G on 14-5-16.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DotCNetService.h"

@class ServerRequest;
@class DotCDelegatorArguments;

@interface DotCNetService (Dispatcher)

- (void) dispatchRequest:(ServerRequest*)request arguments:(DotCDelegatorArguments*)arguments;

//- (void) registeDelegator:(id)subject selector:(SEL)selector forOperation:(NSString*)operation andModule:(NSString*)module;
//- (void) removeDelegator:(NSString*)operation forModule:(NSString*)module;
//
//- (void) registeModuleDelegator:(id)subject selector:(SEL)selector forOperation:(NSString*)operation andModule:(NSString*)module;
//- (void) removeModuleDelegator:(NSString*)operation forModule:(NSString*)module;

@end
 
