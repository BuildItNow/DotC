//
//  DelegatorManager.m
//  dotc-imagemanager
//
//  Created by Yang G on 15-10-10.
//  Copyright (c) 2015年 .C . All rights reserved.
//

#import "DotCDefines.h"
#import "DotCDelegatorManager.h"

static NSString* subjectToString(id subject)
{
    return [NSString stringWithFormat:@"%p#%s", (void*)subject, object_getClassName(subject)];
}

@interface OnceSupportDelegator : DotCDelegator
{
    DotCDelegatorID       _onceDelegatorID;
}

@end

@implementation OnceSupportDelegator

- (void) dealloc
{
    [_onceDelegatorID release];
    _onceDelegatorID = nil;
    
    [super dealloc];
}

- (bool) once
{
    return _onceDelegatorID != nil;
}

- (DotCDelegatorID) delegatorID
{
    return _onceDelegatorID ? _onceDelegatorID : [super delegatorID];
}

- (void) setOnceDelegatorID : (DotCDelegatorID) onceDelegatorID
{
    _onceDelegatorID = [onceDelegatorID copy];
}

@end

@interface DotCDelegatorManager()
{
    NSMutableDictionary*     _subject2Delegators;
    NSMutableDictionary*     _id2Delegators;
    uint                     _nextOnceID;
    DotCDelegatorArguments*  _sharedArguments;
}

@end

@implementation DotCDelegatorManager

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _subject2Delegators = STRONG_OBJECT(NSMutableDictionary, init);
    _id2Delegators      = STRONG_OBJECT(NSMutableDictionary, init);
    _nextOnceID         = 1;
    _sharedArguments    = STRONG_OBJECT(DotCDelegatorArguments, init);
    
    return self;
    
}

- (void) dealloc
{
    [_sharedArguments release];
    [_subject2Delegators release];
    [_id2Delegators release];
    
    [super dealloc];
}

- (NSMutableDictionary*) subjectDelegators:(id) subject create:(BOOL) create
{
    NSString* key = subjectToString(subject);
    
    NSMutableDictionary* ret = [_subject2Delegators objectForKey:key];
    if(!ret && create)
    {
        ret = WEAK_OBJECT(NSMutableDictionary, init);
        
        [_subject2Delegators setObject:ret forKey:key];
    }
    
    return ret;
}

- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector block:(DotCDelegatorBlock) block userdata:(id)userData strong:(bool)userDataIsStrong once:(bool)once
{
    
    DotCDelegatorID delegatorID = nil;
    if(once)
    {
        delegatorID = [NSString stringWithFormat:@"once#%d", _nextOnceID];
        ++_nextOnceID;
    }
    else if(block)
    {
        delegatorID = [DotCDelegator generateDelegatorID:subject block:block userData:userData];
    }
    else if(selector && subject)
    {
        delegatorID = [DotCDelegator generateDelegatorID:subject selector:selector userData:userData];
    }
    else
    {
        return INVALID_DELEGATOR;
    }
    
    if(!once && [_id2Delegators objectForKey:delegatorID])
    {
        return delegatorID;
    }
    
    OnceSupportDelegator* delegator = WEAK_OBJECT(OnceSupportDelegator, init);
    
    delegator.subject  = subject;
    delegator.selector = selector;
    delegator.block    = block;
    [delegator setUserData:userData strong:userDataIsStrong];
    
    if(once)
    {
        delegator.onceDelegatorID = delegatorID;
    }
    
    
    // add to _subject2Delegators
    if(subject)
    {
        NSMutableDictionary* delegators = [self subjectDelegators:subject create:TRUE];
        [delegators setObject:delegator forKey:delegatorID];
    }
    
    // add to _id2Delegators
    [_id2Delegators setObject:delegator forKey:delegatorID];
    
    return delegatorID;
}

- (DotCDelegatorID) addDelegator:(id) subject block:(DotCDelegatorBlock)block
{
    return [self addDelegator:subject selector:nil block:block userdata:nil strong:false once:false];
}

- (DotCDelegatorID) addDelegator:(id) subject block:(DotCDelegatorBlock)block weakUserData:(id)userData
{
    return [self addDelegator:subject selector:nil block:block userdata:userData strong:false once:false];
}

- (DotCDelegatorID) addDelegator:(id) subject block:(DotCDelegatorBlock)block strongUserData:(id)userData
{
    return [self addDelegator:subject selector:nil block:block userdata:userData strong:true once:false];
}


- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector
{
    return [self addDelegator:subject selector:selector block:nil userdata:nil strong:false once:false];
}

- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector weakUserData:(id)userData
{
    return [self addDelegator:subject selector:selector block:nil userdata:userData strong:false once:false];
}

- (DotCDelegatorID) addDelegator:(id) subject selector:(SEL) selector strongUserData:(id)userData
{
    return [self addDelegator:subject selector:selector block:nil userdata:userData strong:true once:false];
}

- (DotCDelegatorID) onceDelegator:(id) subject selector:(SEL) selector
{
    return [self addDelegator:subject selector:selector block:nil userdata:nil strong:false once:true];
}

- (DotCDelegatorID) onceDelegator:(id) subject selector:(SEL) selector weakUserData:(id)userData
{
    return [self addDelegator:subject selector:selector block:nil userdata:userData strong:false once:true];
}

- (DotCDelegatorID) onceDelegator:(id) subject selector:(SEL) selector strongUserData:(id)userData
{
    return [self addDelegator:subject selector:selector block:nil userdata:userData strong:true once:true];
}

- (DotCDelegatorID) onceDelegator:(id) subject block:(DotCDelegatorBlock)block
{
    return [self addDelegator:subject selector:nil block:block userdata:nil strong:false once:true];
}

- (DotCDelegatorID) onceDelegator:(id) subject block:(DotCDelegatorBlock)block weakUserData:(id)userData
{
    return [self addDelegator:subject selector:nil block:block userdata:userData strong:false once:true];
}

- (DotCDelegatorID) onceDelegator:(id) subject block:(DotCDelegatorBlock)block strongUserData:(id)userData
{
    return [self addDelegator:subject selector:nil block:block userdata:userData strong:true once:true];
}

- (DotCDelegatorID) onceDelegator:(DotCDelegatorBlock)block
{
    return [self addDelegator:nil selector:nil block:block userdata:nil strong:false once:true];
}

- (DotCDelegatorID) onceDelegator:(DotCDelegatorBlock)block weakUserData:(id)userData
{
    return[self addDelegator:nil selector:nil block:block userdata:userData strong:false once:true];

}

- (DotCDelegatorID) onceDelegator:(DotCDelegatorBlock)block strongUserData:(id)userData
{
    return [self addDelegator:nil selector:nil block:block userdata:userData strong:true once:true];
}

- (void) removeDelegators:(id) subject
{
    NSMutableDictionary* delegators = [self subjectDelegators:subject create:FALSE];
    
    if(!delegators)
    {
        return ;
    }
    
    [_id2Delegators removeObjectsForKeys:[delegators allKeys]];
   
    [_subject2Delegators removeObjectForKey:subjectToString(subject)];
}

- (void) removeDelegator:(DotCDelegatorID) delegatorID
{
    DotCDelegator* delegator = [_id2Delegators objectForKey:delegatorID];
    if(!delegator)
    {
        return ;
    }
    
    [_id2Delegators removeObjectForKey:delegatorID];
    
    id subject  = delegator.subject;
    if(subject)
    {
        NSMutableDictionary* delegators = [self subjectDelegators:subject create:FALSE];
        assert(delegators);
        [delegators removeObjectForKey:delegatorID];
        
        if([delegators count] == 0)
        {
            [_subject2Delegators removeObjectForKey:subjectToString(subject)];
        }
    }
}

- (id) performDelegator:(DotCDelegatorID) delegatorID arguments:(DotCDelegatorArguments*) arguments
{
    OnceSupportDelegator* delegator = [_id2Delegators objectForKey:delegatorID];
    if(!delegator)
    {
        return nil;
    }
    
    id ret = [delegator perform:arguments ? arguments : _sharedArguments];
    
    if(delegator.once)
    {
        [self removeDelegator:delegatorID];
    }
    
    return ret;
}

+ (instancetype) globalDelegatorManager
{
    static DotCDelegatorManager* s_instance = nil;
    if (s_instance == nil){
        
        s_instance = STRONG_OBJECT(DotCDelegatorManager, init);
    }
    
    return s_instance;
}

@end
