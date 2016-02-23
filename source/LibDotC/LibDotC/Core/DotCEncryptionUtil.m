//
//  EncryptionUtil.m
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "DotCEncryptionUtil.h"

#import <CommonCrypto/CommonDigest.h>

static uint32_t s_table[256] = {0};
const uint32_t DEFAULT_SEED       = 0xFFFFFFFFL;
const uint32_t DEFAULT_POLYNOMIAL = 0xEDB88320L;

static void generateCRC32Table(uint32_t *pTable, uint32_t poly)
{
    for (uint32_t i = 0; i <= 255; i++)
    {
        uint32_t crc = i;
        
        for (uint32_t j = 8; j > 0; j--)
        {
            if ((crc & 1) == 1)
                crc = (crc >> 1) ^ poly;
            else
                crc >>= 1;
        }
        pTable[i] = crc;
    }
}

static uint32_t crc32WithSeed(uint8_t* pBytes, uint32_t length, uint32_t seed)
{
    
    static dispatch_once_t  _;
    dispatch_once(&_, ^
                  {
                      generateCRC32Table(s_table, DEFAULT_POLYNOMIAL);
                  });
    
    uint32_t crc = seed;
    while (length--)
    {
        crc = (crc>>8) ^ s_table[(crc & 0xFF) ^ *pBytes++];
    }
    
    return crc ^ 0xFFFFFFFFL;
}

@implementation DotCEncryptionUtil

+ (NSString*) md5:(NSString*)src
{
    // Create pointer to the string as UTF8
	const char *ptr = [src UTF8String];
    
	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
	// Convert MD5 value in the buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
	return output;
}

+ (uint32_t) crc32:(uint8_t*) src length:(uint32_t)length
{
    return crc32WithSeed(src, length, DEFAULT_SEED);
}

+ (uint32_t) crc32:(uint8_t*) src length:(uint32_t)length seed:(uint32_t) seed
{
    return crc32WithSeed(src, length, seed);
}

@end

@implementation NSData (CRC)
- (uint32_t) crc32
{
    return [DotCEncryptionUtil crc32:(uint8_t*)self.bytes length:(uint32_t)self.length];
}

@end

