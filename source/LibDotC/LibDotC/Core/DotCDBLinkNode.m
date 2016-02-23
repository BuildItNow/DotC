//
//  DBLinkNode.m

//
//  Created by Yang G on 14-7-16.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCDBLinkNode.h"

@interface DotCDBLinkNode()
{
    id              _value;
    
    DotCDBLinkNode*     _prev;
    DotCDBLinkNode*     _next;
}

@end

@implementation DotCDBLinkNode

- (id) value
{
    return _value;
}

- (void) setValue:(id)value
{
    _value = value;
}

- (DotCDBLinkNode*) prev
{
    return _prev;
}

- (DotCDBLinkNode*) next
{
    return _next;
}

- (void) linkBefore:(DotCDBLinkNode*)listNode   
{
    APP_ASSERT(listNode);
    
    _next = listNode;
    _prev = listNode->_prev;
    
    if(_prev)
    {
        _prev->_next = self;
    }
    
    _next->_prev = self;
}

- (void) linkAfter:(DotCDBLinkNode*)listNode
{
    APP_ASSERT(listNode);
    
    _prev = listNode;
    _next = listNode->_next;
    
    _prev->_next = self;
    if(_next)
    {
        _next->_prev = self;
    }
}

- (void) unLink
{
    if(_prev)
    {
        _prev->_next = _next;
    }
    
    if(_next)
    {
        _next->_prev = _prev;
    }
    
    _prev = nil;
    _next = nil;
}

+ (instancetype) nodeFrom:(id)value
{
    DotCDBLinkNode* ret = WEAK_OBJECT(self, init);
    
    ret.value = value;
    
    return ret;
}

@end
