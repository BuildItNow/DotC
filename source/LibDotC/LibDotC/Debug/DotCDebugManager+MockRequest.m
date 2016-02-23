//
//  DebugManager+MockRequest.m

//
//  Created by Yang G on 14-5-20.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCDebugManager+MockRequest.h"
#import "DotCServerRequest.h"
#import "DotCNetService.h"


@implementation DotCDebugManager (MockRequest)

- (NSString*) generateRequestKey:(NSString*)operation module:(NSString*)module
{
    return [NSString stringWithFormat:@"%@#%@", operation, module];
}

- (NSDictionary*) getRsponseJasonData:(NSString*)operation module:(NSString*)module option:(DotCServerRequestOption*)option
{
    if([option option:@"mjrefresh"])
    {
        NSString* refreshName = [option option:@"refreshName"];
        assert(refreshName);
        NSString* pageIndex   = [option option:@"pageIndex"];
        assert(pageIndex);
        
        NSString* pagesName = [_refreshRequestDataSelector objectForKey:refreshName];
        if(!pagesName)
        {
            return FALSE;
        }
        NSArray* refreshPages = [_refreshDatabase objectForKey:pagesName];
        assert(refreshPages);
        
        //NSArray* refreshPages = [_refreshRequestDataSelector objectForKey:refreshName];
        NSArray* refreshPage  = [refreshPages objectAtIndex:pageIndex.intValue];
        assert(refreshPage);
        
        int totalCount = 0;
        int totalPages = 0;
        for(NSArray* page in refreshPages)
        {
            ++totalPages;
            
            totalCount += page.count;
        }
        
        return @{@"PageIndex":pageIndex,@"TotalCount":@(totalCount),@"Value":refreshPage};
    }
    else
    {
        NSString* key = [self generateRequestKey:operation module:module];
    
        NSString* dataKey = [_mockRequestDataSelector objectForKey:key];
    
        return [_mockRequestDatabase objectForKey:dataKey];
    }
}

- (BOOL) isMockRequest:(NSString*)operation module:(NSString*)module option:(DotCServerRequestOption*)option;
{
    if([option option:@"mjrefresh"])
    {
        NSString* refreshName = [option option:@"refreshName"];
        assert(refreshName);
        NSString* pageIndex   = [option option:@"pageIndex"];
        assert(pageIndex);
        
        NSString* pagesName = [_refreshRequestDataSelector objectForKey:refreshName];
        if(!pagesName)
        {
            return FALSE;
        }
        NSArray* refreshPages = [_refreshDatabase objectForKey:pagesName];
        assert(refreshPages);
        
        if(refreshPages.count <= pageIndex.intValue)
        {
            return FALSE;
        }
        
        return TRUE;
    }
    else
    {
        NSString* key = [self generateRequestKey:operation module:module];
        
        return [_mockRequestDataSelector objectForKey:key] != nil;
    }
}

- (void) mockRequestDispatch:(MockRequest*)request
{
    [request autorelease];
    
    [DOTC_NET_SERVICE requestHandler:request responseObject:request.responseObject error:nil];
}

- (DotCServerRequest*) doMockRequest:(NSString*)operation module:(NSString*)module option:(DotCServerRequestOption*)option
{
    id oriData = [self getRsponseJasonData:operation module:module option:option];
    assert(oriData);
    
    NSString* version = nil;
    id srcData = oriData;
    if([srcData isMemberOfClass:[@{} class]])   // Is dictionary
    {
        version = [oriData objectForKey:@"version"];
        
        if([oriData objectForKey:@"redirect"])
        {
            srcData = [oriData objectForKey:@"redirect"];
        }
    }
    assert(srcData);

    NSMutableDictionary* jsonData = WEAK_OBJECT(NSMutableDictionary, init);
    
//    if(!version || [version isEqualToString:@"2.1"])
//    {
//        [jsonData setObject:@"1" forKey:@"Success"];
//        [jsonData setObject:@"" forKey:@"Message"];
//        [jsonData setObject:@"0" forKey:@"StatusCode"];
//        [jsonData setObject:srcData forKey:@"Value"];
//    }
//    else if([version isEqualToString:@"2.0"])
//    {
//        [jsonData setObject:@"成功" forKey:@"OperationDescription"];
//        [jsonData setObject:@"1" forKey:@"OperationState"];
//        [jsonData setObject:@"null" forKey:@"OtherInfo"];
//        [jsonData setObject:srcData forKey:@"Result"];
//    }
//    else if([version isEqualToString:@"0.0"])
//    {
//        [jsonData setValuesForKeysWithDictionary:srcData];
//    }
    
    MockRequest* request = STRONG_OBJECT(MockRequest, init);    // autorelease in mockRequestDispatch
    
    [request setUserData:@"yes" key:@"fromMock"];
    
    [request setResponseObject:jsonData];
    
    [self performSelector:@selector(mockRequestDispatch:) withObject:request afterDelay:1];
    
    return request;
}

@end
