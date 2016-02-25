//
//  DictionaryWrapper.h
//  LibDotC
//
//  Created by Yang G on 14-10-22.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCDictionaryWrapper : NSObject

- (instancetype) initWith:(NSDictionary*)dictionary;

- (id) get:(NSString*)name;
- (NSString*) getString:(NSString*)name;
- (DotCDictionaryWrapper*) getDictionaryWrapper:(NSString*)name;
- (NSDictionary*) getDictionary:(NSString*)name;
- (NSArray*) getArray:(NSString*)name;
- (int64_t) getInteger:(NSString*)name;
- (double) getDouble:(NSString*)name;

- (float) getFloat:(NSString*)name;
- (int) getInt:(NSString*)name;
- (long) getLong:(NSString*)name;
- (BOOL) getBool:(NSString*)name;


- (void) setDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) dictionary;
- (instancetype) wrapper;

+ (instancetype) wrapperFromDictionary:(NSDictionary*)dictionary;

@end

@interface NSDictionary (Wrapper)

- (DotCDictionaryWrapper*) wrapper;
- (instancetype) dictionary;

@end

@interface DotCWDictionaryWrapper : DotCDictionaryWrapper

- (void) set:(NSString*)name value:(id)value;
- (void) set:(NSString*)name bool:(BOOL)value;
- (void) set:(NSString*)name int:(int)value;
- (void) set:(NSString*)name string:(NSString*)value;
- (void) set:(NSString*)name float:(float)value;
- (void) set:(NSString*)name double:(double)value;
- (void) set:(NSString*)name long:(long)value;

@end

@interface DotCWPDictionaryWrapper : DotCWDictionaryWrapper

+ (instancetype) wrapperFromName:(NSString*)name;

@end
