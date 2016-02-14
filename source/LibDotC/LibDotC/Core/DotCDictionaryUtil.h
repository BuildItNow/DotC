//
//  DictionaryUtil.h
//  DotC
//
//  Created by Yang G on 14-10-18.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCDictionaryUtil : NSObject
+ (id) object:(id)object to:(Class)class;
+ (int64_t) objectToInteger:(id)object;
+ (int) objectToInt:(id)object;
+ (long) objectToLong:(id)object;
+ (double) objectToDouble:(id)object;
+ (float) objectToFloat:(id)object;
+ (BOOL) objectToBool:(id)object;


@end
