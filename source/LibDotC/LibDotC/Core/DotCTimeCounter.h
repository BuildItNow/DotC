//
//  TimeCounter.h
//
//  Created by Yang G on 14-6-18.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCTimeCounter : NSObject
- (void) setTimer:(float)interval repeat:(BOOL)isRepeat;
- (void) setTimer:(float)interval repeatCount:(int)count;
- (void) setDelegator:(id)subject selector:(SEL)selector;
- (BOOL) isCounting;
- (void) deSetup;
- (void) setup;

+ (instancetype) counterFrom:(id)subject selector:(SEL)selector interval:(float)interval;

@end
