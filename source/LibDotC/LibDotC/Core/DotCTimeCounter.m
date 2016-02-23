//
//  TimeCounter.m
//
//  Created by Yang G on 14-6-18.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCTimeCounter.h"
#import "DotCDelegator.h"

@interface DotCTimeCounter()
{
    NSTimer*        _timer;
    float           _interval;
    BOOL            _isRepeat;
    int             _repeatCount;
    int             _currentCount;
    DotCDelegator*      _delegator;
}

@end

@implementation DotCTimeCounter
{
    DotCDelegatorArguments*     _arguments;
}

- (instancetype) init
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _arguments = STRONG_OBJECT(DotCDelegatorArguments, init);
    
    _repeatCount = -1;
    _currentCount = 0;
    
    return self;
}

- (void) dealloc
{
    _timer = nil;
    [_delegator release];
    [_arguments release];
    
    [super dealloc];
}

- (void) setTimer:(float)interval repeat:(BOOL)isRepeat
{
    assert(!_timer);
    
    _interval = interval;
    _isRepeat = isRepeat;
    
    _repeatCount  = -1;
    _currentCount = 0;
}

- (void) setTimer:(float)interval repeatCount:(int)count
{
    [self setTimer:interval repeat:TRUE];
    
    _repeatCount  = count;
    _currentCount = 0;
}

- (void) setDelegator:(id)subject selector:(SEL)selector
{
    [_delegator release];
    
    _delegator = STRONG_OBJECT(DotCDelegator, init);
    [_delegator setSubject:subject selector:selector];
}

// Note : Will stop timer and clean delegator info
- (void) deSetup
{
    [_delegator release];
    _delegator = nil;
    
    [_timer invalidate];
    _timer = nil;
}

// Note : Must setTimer and setDelegator before call setup
- (void) setup
{
    assert(_delegator);
    assert(![self isCounting]);
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_interval target:self selector:@selector(onCount:) userInfo:nil repeats:_isRepeat];

    _currentCount = 0;
}

- (BOOL) isCounting
{
    return _timer != nil;
}

- (void)onCount:(NSTimer *)timer
{
    assert(timer == _timer);
    
    if(_delegator)
    {
        [_delegator perform:_arguments];
    
        if(_repeatCount > 0)
        {
            ++_currentCount;
            if(_currentCount >= _repeatCount)
            {
                [self deSetup];
            }
        }
    }
}

+ (instancetype) counterFrom:(id)subject selector:(SEL)selector interval:(float)interval
{
    DotCTimeCounter* ret = WEAK_OBJECT(self, init);
    [ret setTimer:interval repeat:TRUE];
    [ret setDelegator:subject selector:selector];
    
    [ret setup];
    
    return ret;
}


@end
