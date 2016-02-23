//
//  EncryptionUtil.h
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCEncryptionUtil : NSObject

+ (NSString*) md5:(NSString*)src;
+ (uint32_t) crc32:(uint8_t*) src length:(uint32_t)length;
+ (uint32_t) crc32:(uint8_t*) src length:(uint32_t)length seed:(uint32_t) seed;

@end

@interface NSData (CRC)

- (uint32_t) crc32;

@end
