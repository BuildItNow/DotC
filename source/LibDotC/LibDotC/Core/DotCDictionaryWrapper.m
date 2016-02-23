//
//  DictionaryWrapper.m
//  LibDotC
//
//  Created by Yang G on 14-10-22.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import "DotCDictionaryWrapper.h"
#import "DotCDictionaryUtil.h"

@interface StackItem : NSObject

@property (retain, nonatomic) NSDictionary* object;
@property (copy, nonatomic) NSString* key;

@end

@implementation StackItem

@synthesize object = _object, key = _key;

- (void) dealloc
{
    [_object release];
    [_key release];
    
    [super dealloc];
}

+ (instancetype) itemFrom:(NSDictionary*)object key:(NSString*)key
{
    StackItem* ret = WEAK_OBJECT(StackItem, init);
    ret.object = object;
    ret.key    = key;
    
    return ret;
}

@end

@implementation DotCDictionaryWrapper
{
@protected
    NSDictionary*     _dictionary;
@private
}

- (instancetype) initWith:(NSDictionary*)dictionary
{
    if(!(self = [super init]))
    {
        return nil;
    }
    
    [self setDictionary:dictionary];
    
    return self;
}

- (void)dealloc
{
    [_dictionary release];
    
    [super dealloc];
}

- (void) setDictionary:(NSDictionary*)dictionary
{
    [_dictionary release];
    _dictionary = [dictionary retain];
}

- (NSDictionary*) dictionary
{
    return _dictionary;
}


- (id) get:(NSString*)name
{
    if(!_dictionary)
    {
        return nil;
    }
    
    NSArray* components = [name componentsSeparatedByString:@"."];
    
    NSDictionary* object = _dictionary;
    id value = nil;
    for(NSString* key in components)
    {
        if([object isKindOfClass:[DotCDictionaryWrapper class]])
        {
            value = [(DotCDictionaryWrapper*)object get:key];
        }
        else if([object isKindOfClass:[NSDictionary class]])
        {
            value  = [object objectForKey:key];
        }
        else
        {
            value = nil;
        }
        
        object = value;
    }
    
    return value;
}

- (NSString*) getString:(NSString*)name
{
    return [DotCDictionaryUtil object:[self get:name] to:[NSString class]];
}

- (DotCDictionaryWrapper*) getDictionaryWrapper:(NSString*)name
{
    id ret = [self get:name];
    
    if([ret isKindOfClass:[DotCDictionaryWrapper class]])
    {
        
    }
    else
    {
        ret = [DotCDictionaryWrapper wrapperFromDictionary:[DotCDictionaryUtil object:ret to:[NSDictionary class]]];
    }
    
    return ret;
}

- (NSDictionary*) getDictionary:(NSString*)name
{
    id ret = [self get:name];
    
    if([ret isKindOfClass:[DotCDictionaryWrapper class]])
    {
        ret = ((DotCDictionaryWrapper*)ret).dictionary;
    }
    else
    {
        ret = [DotCDictionaryUtil object:ret to:[NSDictionary class]];
    }
    
    return ret;
}

- (NSArray*) getArray:(NSString*)name
{
    return [DotCDictionaryUtil object:[self get:name] to:[NSArray class]];
}

- (int64_t) getInteger:(NSString*)name
{
    return [DotCDictionaryUtil objectToInteger:[self get:name]];
}

- (double) getDouble:(NSString*)name
{
    return [DotCDictionaryUtil objectToDouble:[self get:name]];
}

- (float) getFloat:(NSString*)name
{
    return [DotCDictionaryUtil objectToFloat:[self get:name]];
}

- (int) getInt:(NSString*)name
{
    return [DotCDictionaryUtil objectToInt:[self get:name]];
}

- (long) getLong:(NSString*)name
{
    return [DotCDictionaryUtil objectToLong:[self get:name]];
}

- (BOOL) getBool:(NSString*)name
{
    return [DotCDictionaryUtil objectToBool:[self get:name]];
}

- (instancetype) wrapper
{
    return self;
}

- (NSString*)descriptionImpl
{
    return [_dictionary description];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"DictionaryWrapper\n%@", [self descriptionImpl]];
}

+ (instancetype) wrapperFromDictionary:(NSDictionary*)dictionary
{
    if(!dictionary)
    {
        return nil;
    }
    
    return WEAK_OBJECT(self, initWith:dictionary);
}

@end

@implementation NSDictionary (Wrapper)

- (DotCDictionaryWrapper*) wrapper
{
    return [DotCDictionaryWrapper wrapperFromDictionary:self];
}

- (instancetype) dictionary
{
    return self;
}

@end

@implementation WDictionaryWrapper

- (void) reset:(NSArray*)stack at:(int)index key:(NSString*)key value:(id)value
{
    if(index == 0) // setup on _dictionary
    {
        [_dictionary release];
        _dictionary = [value retain];
        
        return ;
    }
    
    id        parent    = [stack[index] object];
    NSString* parentKey = [stack[index] key];
    @try
    {
        if([parent isKindOfClass:[WDictionaryWrapper class]])
        {
            [(WDictionaryWrapper*)parent set:key value:value];
        }
        else if(value)
        {
            [parent setValue:value forKey:key];
        }
        else
        {
            [parent removeObjectForKey:key];
        }
    }
    @catch (NSException *exception)
    {
        parent = WEAK_OBJECT(NSMutableDictionary, initWithDictionary:[parent dictionary]);
        
        if(value)
        {
            [parent setValue:value forKey:key];
        }
        else
        {
            [parent removeObjectForKey:key];
        }
                
        [stack[index] setObject:parent];
        
        [self reset:stack at:index-1 key:parentKey value:parent];
    }
}

- (void) set:(NSString*)name value:(id)value
{
    if(!_dictionary)
    {
        _dictionary = STRONG_OBJECT(NSMutableDictionary, init);
    }
    
    NSArray* components = [name componentsSeparatedByString:@"."];
    
    NSMutableArray* stack = WEAK_OBJECT(NSMutableArray, init);
    [stack addObject:WEAK_OBJECT(StackItem, init)];  // Place holder, _dictionary parent
    [stack addObject:[StackItem itemFrom:_dictionary key:@""]]; // _dictionary
    
    NSMutableDictionary* object = (NSMutableDictionary*)_dictionary;
    
    int i = 0;
    int i_sz = ((int)components.count) - 1;
    for(i=0; i<i_sz; ++i)
    {
        NSString* key = components[i];
        
        if([object isKindOfClass:[DotCDictionaryWrapper class]])
        {
            object = [(DotCDictionaryWrapper*)object get:key];
        }
        else
        {
            object = [object objectForKey:key];
        }
        
        if(![object isKindOfClass:[DotCDictionaryWrapper class]])
        {
            object = [DotCDictionaryUtil object:object to:[NSDictionary class]];
        }
        
        if(!object)
        {
            object = WEAK_OBJECT(NSMutableDictionary, init);
            
            [self reset:stack at:(int)stack.count-1 key:key value:object];
        }
        
        [stack addObject:[StackItem itemFrom:object key:key]];
    }
    
    [self reset:stack at:(int)stack.count-1 key:components.lastObject value:value];
}

- (void) set:(NSString*)name bool:(BOOL)value
{
    [self set:name value:[NSNumber numberWithBool:value]];
}

- (void) set:(NSString*)name int:(int)value
{
    [self set:name value:[NSNumber numberWithInt:value]];
}

- (void) set:(NSString*)name string:(NSString*)value
{
    [self set:name value:value];
}

- (void) set:(NSString*)name float:(float)value
{
    [self set:name value:[NSNumber numberWithFloat:value]];
}

- (void) set:(NSString*)name double:(double)value
{
    [self set:name value:[NSNumber numberWithDouble:value]];
}

- (void) set:(NSString*)name long:(long)value
{
    [self set:name value:[NSNumber numberWithLong:value]];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"WDictionaryWrapper\n%@", [self descriptionImpl]];
}

@end

@interface WPDictionaryWrapper()
{
    NSString*       _persistName;
    BOOL            _dirty;
}

@end

@implementation WPDictionaryWrapper

- (instancetype) initWithName:(NSString*)name
{
    if(!(self = [super init]))
    {
        return nil;
    }
    
    _persistName = [name copy];
    
    NSDictionary* dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:_persistName];
    
    if(dictionary)
    {
        dictionary = [[dictionary copy] autorelease];
        [self setDictionary:dictionary];
    }
    
    return self;
}

- (void) dealloc
{
    [_persistName release];
    
    [super dealloc];
}

- (BOOL) dirty
{
    return _dirty;
}

- (void) setDirty:(BOOL)dirty
{
    _dirty = dirty;
}

- (void) set:(NSString*)name value:(id)value
{
    if([value isKindOfClass:[DotCDictionaryWrapper class]]) // Persist Wrapper can't set DictionaryWrapper
    {
        value = [value dictionary];
    }
    
    _dirty = TRUE;
    
    [super set:name value:value];
    
//    dispatch_async(dispatch_get_main_queue(), ^()
//                   {
                       if(self.dirty)
                       {
                           [[NSUserDefaults standardUserDefaults] setObject:self.dictionary forKey:_persistName];
                           [[NSUserDefaults standardUserDefaults] synchronize];
                           
                           self.dirty = FALSE;
                       }
//                   }
//                   );
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"WPDictionaryWrapper\n%@", [self descriptionImpl]];
}

+ (instancetype) wrapperFromName:(NSString*)name
{
    return WEAK_OBJECT(self, initWithName:name);
}

@end

//WDictionaryWrapper* w = WEAK_OBJECT(WDictionaryWrapper, init);
//
//[w set:@"a.b" value:WEAK_OBJECT(WDictionaryWrapper, init)];
//[w set:@"a.b.c" value:@"hello World"];
//
//NSLog(@"== %@", w);
//
//[w set:@"a.d" value:[DictionaryWrapper wrapperFromDictionary:@{@"e":@"Hello", @"f":WEAK_OBJECT(WDictionaryWrapper, init)}]];
//[w set:@"a.d.c" value:@"hello World"];
//
//NSLog(@"== %@", w);
//
//[w set:@"a.d.f.a" value:@"Hello"];
//
//NSLog(@"== %@", w);
//
//[w set:@"a.e" value:@{@"e":@"Hello"}];
//[w set:@"a.e.a" value:@"Hello"];
//
//NSLog(@"== %@", w);
//
//[w set:@"a.f" value:WEAK_OBJECT(WPDictionaryWrapper, init)];
//[w set:@"a.f.a" value:[WDictionaryWrapper wrapperFromDictionary:@{@"e":@"Hello"}]];
//
//NSLog(@"== %@", w);
//
//[w set:@"a.b.c" value:nil];
//
//[w set:@"a.d.e" value:nil];
//
//NSLog(@"== %@", w);