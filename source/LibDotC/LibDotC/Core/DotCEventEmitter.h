//
//  EventEmitter.h
//  LibDotC
//
//  Created by Yang G on 14-10-27.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString*    EE_ARGUMENT_EVENT;

@interface DotCEventEmitter : NSObject

- (void) on:(NSString*)event object:(id)object selector:(SEL)selector;
- (void) once:(NSString*)event object:(id)object selector:(SEL)selector;
- (void) remove:(NSString*)event object:(id)object selector:(SEL)selector;
- (void) fire:(NSString*)event arguments:(DotCDelegatorArguments*)arguments;

@end
