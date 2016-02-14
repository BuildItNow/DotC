//
//  Cache.m
//  DotC
//
//  Created by Yang G on 14-7-5.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "Cache.h"

@interface DotCFileCache()
{
    NSString*                  _path;
    NSMutableDictionary*       _indexer;
}

@end

@implementation DotCFileCache

- (instancetype) initWithPath:(NSString*)path
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _path = [path copy];
    _indexer = STRONG_OBJECT(NSMutableDictionary, init);
    
    return self;
}

- (NSString*) cacheFileName:(NSString*)key
{
    return [_path stringByAppendingPathComponent:key];
}

- (void) save:(NSString*)key data:(NSData*)data
{
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:_path])
    {
        [fm createDirectoryAtPath:_path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* name = [self cacheFileName:key];
    
    FILE* file = fopen([name cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if(!file)
    {
        goto OPERATION_FAIL;
    }
    
    if(fwrite(data.bytes, data.length, 1, file) != 1)
    {
        goto OPERATION_FAIL;
    }
    
    fflush(file);
    fclose(file);
    
    [_indexer setObject:name forKey:key];
    
    return ;
OPERATION_FAIL:
    if(file)
    {
        fclose(file);
        file = NULL;
        
        // Delete the file
        [[NSFileManager defaultManager] removeItemAtPath:name error:nil];
    }
    
    return ;
}

- (NSData*) cacheData:(NSString*)key
{
    FILE* file   = NULL;
    void* buffer = NULL;
    NSData* data = nil;
    
    BOOL inIndexer = TRUE;
    NSString* name = [_indexer objectForKey:key];
    if(!name) // Check at disk
    {
        name = [self cacheFileName:key];
        inIndexer = FALSE;
    }
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:name])
    {
        goto OPERATION_FAIL;
    }
    
    file = fopen([name cStringUsingEncoding:NSASCIIStringEncoding], "rb");
    if(!file)
    {
        goto OPERATION_FAIL;
    }
    
    fseek(file, 0, SEEK_END);
    size_t len    = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    buffer = malloc(len+1);
    if(fread(buffer, len, 1, file) != 1)
    {
        free(buffer);
        goto OPERATION_FAIL;
    }
    
    data = [NSData dataWithBytesNoCopy:buffer length:len];
    if(!inIndexer)
    {
        [_indexer setObject:name forKey:key];
    }
    
    fclose(file);
    file = NULL;
    
    return data;
OPERATION_FAIL:
    if(file)
    {
        fclose(file);
        file = NULL;
    }
    
    if(inIndexer)
    {
        [_indexer removeObjectForKey:key];
    }
    return nil;
}

- (void) clear:(NSString*)key
{
    [_indexer removeObjectForKey:key];
    
    // Delete the file
    [[NSFileManager defaultManager] removeItemAtPath:[self cacheFileName:key] error:nil];
}

- (void)    clearAll
{
    [_indexer removeAllObjects];
    
    // Will delete _path directory too
    [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

+ (instancetype) cacheFromPath:(NSString*)path
{
    DotCFileCache* ret = WEAK_OBJECT(self, initWithPath:path);
    
    return ret;
}

@end

#import "FMDatabase.h"

@interface DotCDatabaseCache()
{
    FMDatabase*     _db;
    NSString*       _tableName;
}

@end

@implementation DotCDatabaseCache

- (instancetype) initWithName:(NSString*)name
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    if(![self initDatabase:name])
    {
        //[self autorelease];
        
        return nil;
    }
    
    return self;
}

- (void) dealloc
{
    [self releaseDatabase];
    
    [super dealloc];
}

- (BOOL) initDatabase:(NSString*)name
{
    NSString* path = [DotCPathUtil databaseCacheRoot];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil  error:nil];
    }
    
    path = [path stringByAppendingPathComponent:@"cache.db"];
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    
    if(!db)
    {
        NSLog(@"Create database cache Fail");
    
        goto OPERATION_FAIL;
    }

    if (![db open])
    {
        NSLog(@"Open database cache Fail");
    
        goto OPERATION_FAIL;
    }

    APP_ASSERT(_tableName == nil);
    _tableName = [name copy];
    
    APP_ASSERT(_db == nil);

    _db = [db retain];

    [_db setShouldCacheStatements:YES];

    // Check database version
//    {
//        [_db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id TEXT PRIMARY KEY, version INTEGER)", TABLE_VERSION]];
//    
//        int oldVersion = -1;
//    
//        FMResultSet* result = [_db executeQuery:[NSString stringWithFormat:@"SELECT version FROM %@ WHERE id=\'version\'", TABLE_VERSION]];
//        if(result.next)
//        {
//            oldVersion = [result intForColumn:@"version"];
//        }
//        [result close];
//    
//        if(oldVersion != IMAGE_DATABASE_VERSION)    // Clean all the datas
//        {
//            NSString* insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, version) VALUES (\'version\', %d)",
//                            TABLE_VERSION,
//                            IMAGE_DATABASE_VERSION];
//            [_db executeUpdate:insert];
//        
//            [_db executeUpdate:[NSString stringWithFormat:@"DROP TABLE %@", TABLE_IMAGES]];
//        
//            NSLog(@"IMAGE_DATABASE_VERSION is incorrect, clean all old datas");
//        }
//    }

    [_db executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id TEXT PRIMARY KEY, data BLOB, dataSize INTEGER, lastUpdateTime INTEGER)", _tableName]];

    if ([_db hadError])
    {
        NSLog(@"Create Table Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    
        goto OPERATION_FAIL;
    }

    return TRUE;

OPERATION_FAIL:
    [self releaseDatabase];

    return FALSE;
}

- (void) releaseDatabase
{
    if(_db)
    {
        [_db close];
        [_db release];
        _db = nil;
    }
    
    [_tableName release];
    _tableName = nil;
}


- (void)    save:(NSString*)key data:(NSData*)data
{
    key = key.lowercaseString;
    unsigned long lastUpdateTime = [[NSDate date] timeIntervalSince1970];
    unsigned long dataSize       = (unsigned long)data.length;
    
    NSString* insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (id, data, dataSize, lastUpdateTime) VALUES (\'%@\', ?, %lu, %lu)",
                        _tableName,
                        key,
                        dataSize,
                        lastUpdateTime];
    
    BOOL ret = FALSE;
    ret = [_db executeUpdate:insert, data];
    if(!ret)
    {
        NSLog(@"\nFMDatabase Fail %d\nDesc %@", _db.lastErrorCode, _db.lastErrorMessage);
    }
}

- (NSData*) cacheData:(NSString*)key
{
    NSData* ret = nil;
    key = [key lowercaseString];
    
    NSString* select = [NSString stringWithFormat:@"SELECT data FROM %@ WHERE id = \'%@\'", _tableName, key];
    FMResultSet* result = [_db executeQuery:select];
    
    if(result.next)
    {
        ret = [result dataForColumn:@"data"];
    }
    
    [result close];
    
    return ret;
}

- (void)    clear:(NSString*)key
{
    NSString* del = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = \'%@\'", _tableName, key];
    
    [_db executeUpdate:del];
}

- (void)    clearAll
{
    [self clearCache:0.0f];
}

- (void)    clearCache:(float)daysAgo
{
    int time = [[NSDate date] timeIntervalSince1970] - daysAgo*24*60*60;
    NSString* del = [NSString stringWithFormat:@"DELETE FROM %@ WHERE lastUpdateTime<=%d", _tableName, time];
    
    //NSLog(@"Clear ImageDataBase Before %.2f days", daysAgo);
    
    [_db executeUpdate:del];
}

- (int)  getCacheSize
{
    int ret = 0;
    NSString* select = [NSString stringWithFormat:@"SELECT sum(dataSize) AS databaseSize FROM %@", _tableName];
    FMResultSet* result = [_db executeQuery:select];
    if(result.next)
    {
        ret = (int)[result longForColumn:@"databaseSize"];
    }
    
    [result close];
    
    return ret;
}

+ (instancetype) cacheFromName:(NSString*)name
{
    DotCDatabaseCache* ret = WEAK_OBJECT(self, initWithName:name);
    
    return ret;
}

@end
