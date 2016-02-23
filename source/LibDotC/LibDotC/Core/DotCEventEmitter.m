//
//  EventEmitter.m
//  LibDotC
//
//  Created by Yang G on 14-10-27.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCEventEmitter.h"
#import "DotCDBLinkNode.h"

NSString*    EE_ARGUMENT_EVENT = @"EE_ARGUMENT_EVENT";

@interface EventListener : NSObject


@end

@implementation EventListener
{
    DotCDelegator*      _delegator;
}

- (instancetype) initWith:(DotCDelegator*)delegator
{
    if(self = [super init])
    {
        _delegator = delegator;
        [_delegator retain];
    }
    
    return self;
}

- (void) dealloc
{
    [_delegator release];
    
    [super dealloc];
}

- (BOOL) isOnce
{
    return FALSE;
}

- (id) perform:(DotCDelegatorArguments*) arguments
{
    return [_delegator perform:arguments];
}

- (BOOL) isEqualTo:(id)object selector:(SEL)selector
{
    return _delegator.subject == object && _delegator.selector == selector;
}

+ (instancetype) listenerFrom:(id)object selector:(SEL)selector
{
    DotCDelegator* delegator = WEAK_OBJECT(DotCDelegator, init);
    delegator.subject  = object;
    delegator.selector = selector;
    
    return WEAK_OBJECT(self, initWith:delegator);
}

@end

@interface EventOnceListener : EventListener


@end

@implementation EventOnceListener

- (BOOL) isOnce
{
    return TRUE;
}

@end


@interface DotCEventEmitter()
{
    NSMutableDictionary*      _eventListeners;
}

@end

@implementation DotCEventEmitter

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return nil;
    }
    
    _eventListeners = STRONG_OBJECT(NSMutableDictionary, init);
    
    return self;
}

- (void) dealloc
{
    // release all listeners
    for(DotCDBLinkNode* head in _eventListeners.allValues)
    {
        DotCDBLinkNode* pos = head.next;
        DotCDBLinkNode* nxt = nil;
        
        while(pos && pos!= head)
        {
            nxt = pos.next;
            
            [pos unLink];
            
            [pos.value release];
            [pos release];
            
            pos = nxt;
        }
    }
    
    [_eventListeners release];
    _eventListeners = nil;
    
    [super dealloc];
}

- (DotCDBLinkNode*) headNode:(NSString*)event
{
    DotCDBLinkNode* node = [_eventListeners objectForKey:event];
    if(!node)
    {
        node = WEAK_OBJECT(DotCDBLinkNode, init);
        [node linkAfter:node];
        
        [_eventListeners setObject:node forKey:event];
    }
    
    return node;
}

- (void) on:(NSString*)event object:(id)object selector:(SEL)selector
{
    DotCDBLinkNode* node = [self headNode:event];
    
    // Check if exist
    DotCDBLinkNode* pos = node.next;
    while(pos && pos!=node)
    {
        EventListener* listener = pos.value;
        if([listener isEqualTo:object selector:selector])
        {
            return ;
        }
        
        pos = pos.next;
    }
    
    EventListener* listener  = [EventListener listenerFrom:object selector:selector];
    [listener retain];
    
    DotCDBLinkNode* listenerNode = STRONG_OBJECT(DotCDBLinkNode, init);
    listenerNode.value = listener;
    
    [listenerNode linkBefore:node];
}

- (void) once:(NSString*)event object:(id)object selector:(SEL)selector
{
    DotCDBLinkNode* node = [self headNode:event];
    
    // Check if exist
    DotCDBLinkNode* pos = node.next;
    while(pos && pos!=node)
    {
        EventListener* listener = pos.value;
        if([listener isEqualTo:object selector:selector])
        {
            return ;
        }
        
        pos = pos.next;
    }
    
    EventListener* listener  = [EventOnceListener listenerFrom:object selector:selector];
    [listener retain];
    
    DotCDBLinkNode* listenerNode = STRONG_OBJECT(DotCDBLinkNode, init);
    listenerNode.value = listener;
    
    [listenerNode linkBefore:node];
}

- (void) remove:(NSString*)event object:(id)object selector:(SEL)selector
{
    DotCDBLinkNode* node = [_eventListeners objectForKey:event];
    if(!node)
    {
        return ;
    }
    
    DotCDBLinkNode* pos = node.next;
    while(pos && pos!=node)
    {
        EventListener* listener = pos.value;
        if(![listener isEqualTo:object selector:selector])
        {
            pos = pos.next;
            
            continue;
        }
        
        [pos unLink];
        [pos.value release];
        [pos release];
        pos = nil;
        
        return ;
    }

}

- (void) fire:(NSString*)event arguments:(DotCDelegatorArguments*)arguments
{
    DotCDBLinkNode* node = [_eventListeners objectForKey:event];
    if(!node)
    {
        return ;
    }
    
    [arguments setArgument:event for:EE_ARGUMENT_EVENT];
    
    DotCDBLinkNode* pos = node.next;
    DotCDBLinkNode* nxt = nil;
    while(pos && pos!=node)
    {
        nxt = pos.next;
        
        [pos.value perform:arguments];
        if([pos.value isOnce])
        {
            [pos unLink];
            [pos.value release];
            [pos release];
            
            pos = nil;
        }
        
        pos = nxt;
    }
    
    [arguments cleanArgument:EE_ARGUMENT_EVENT];
}

@end
