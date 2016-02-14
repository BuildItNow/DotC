//
//  MJRefreshController.m
//
//  Created by Yang G on 14-5-30.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "MJRefreshController.h"
#import "MJRefresh.h"
#import "DotCDelegatorManager.h"
#import "DotCNetService.h"
#import "DotCDictionaryWrapper.h"

static MJRefreshURLGenerator   s_urlGenerator = nil;
static MJRefreshNetData2MJData s_dataConverter = nil;;
static MJRefreshRequest        s_requester = nil;
static MJRefreshOnRequestDone  s_onRequestDone = nil;
static MJRefreshPrevRequestHandler s_prevRequestHandler = nil;
static MJRefreshPostRequestHandler s_postRequestHandler = nil;
static Class                       s_headerContentViewClass = nil;

DOTC_IMPL_DELEGATOR_FEATURE_CLASS(__DFCMJRefreshController, NSObject)

@interface MJRefreshController()<MJRefreshBaseViewDelegate>
{
    NSString*               _refreshName;
    NSMutableArray*         _refreshData;
    UITableView*            _refreshView;
    
    BOOL                    _dataDone;
    int                     _pageSize;      // Default 9
    
    MJRefreshBaseView*      _header;
    MJRefreshBaseView*      _footer;
    
    MJRefreshURLGenerator   _urlGenerator;
    MJRefreshNetData2MJData _dataConverter;
    MJRefreshRequest        _requester;
    MJRefreshOnRequestDone  _onRequestDone;
    MJRefreshPrevRequestHandler _prevRequestHandler;
    MJRefreshPostRequestHandler _postRequestHandler;
}

@end

@implementation MJRefreshController
{
    BOOL        _needLoading;
}

- (instancetype) initWithView:(UITableView*)refreshView andName:(NSString*)refreshName
{
    if(!(self = [super init]))
    {
        return self;
    }
    
    _refreshView = refreshView;
    [_refreshView retain];
    
    _refreshName = [refreshName copy];
    
    _refreshData = STRONG_OBJECT(NSMutableArray, init);
     _pageSize   = 9;
    _dataDone    = FALSE;
    
    [self setURLGenerator:s_urlGenerator];
    self.dataConverter = s_dataConverter;
    self.requester = s_requester;
    self.onRequestDone = s_onRequestDone;
    self.prevRequestHandler = s_prevRequestHandler;
    self.postRequestHandler = s_postRequestHandler;
    
    return self;
}

- (void) dealloc
{
    [_refreshData release];
    
    [_header release];
    [_footer release];
    [_refreshView release];
    [_refreshName release];
    [_urlGenerator release];
    [_dataConverter release];
    [_requester release];
    [_onRequestDone release];
    [_prevRequestHandler release];
    [_postRequestHandler release];
    
    [super dealloc];
}

- (void) setURLGenerator:(MJRefreshURLGenerator) urlGenerator
{
    [_urlGenerator autorelease];
    
    _urlGenerator = [urlGenerator copy];
}

- (void) setDataConverter:(MJRefreshNetData2MJData) dataConverter
{
    [_dataConverter autorelease];
    
    _dataConverter = [dataConverter copy];
}

- (void) setRequester:(MJRefreshRequest)requester
{
    [_requester autorelease];
    
    _requester = [requester copy];
}

- (void) setOnRequestDone:(MJRefreshOnRequestDone)onRequestDone
{
    [_onRequestDone autorelease];
    
    _onRequestDone = [onRequestDone copy];
}

- (void) setPrevRequestHandler:(MJRefreshPrevRequestHandler)prev
{
    [_prevRequestHandler autorelease];
    
    _prevRequestHandler = [prev copy];
}

- (void) setPostRequestHandler:(MJRefreshPostRequestHandler)post
{
    [_postRequestHandler autorelease];
    
    _postRequestHandler = [post copy];
}

- (void) setPageSize:(int)pageSize
{
    _pageSize = pageSize;
}

- (void) addHeader
{
    assert(_refreshView);
    
    UIView<MJHeaderContentView>* view = nil;
    if(s_headerContentViewClass)
    {
        view = WEAK_OBJECT(s_headerContentViewClass, init);
    }
    
    _header = [MJRefreshCustomHeaderView headerFrom:view];
    _header.scrollView = _refreshView;
    _header.delegate = self;
}

- (void) addFooter
{
    assert(_refreshView);
    
    _footer = [MJRefreshFooterView footer];
    _footer.scrollView = _refreshView;
    _footer.delegate = self;
}

- (void) requestData:(BOOL)byFooter
{
    if(byFooter)
    {
        if(_dataDone)
        {
            [DotCHUDUtil showSuccessWithStatus:@"暂无更多数据"];
            
            [self performSelector:@selector(endRefreshing:) withObject:_footer afterDelay:0.9];
            return ;
        }
    }
    else
    {
        _dataDone = FALSE;
    }
    
    int pageIndex = byFooter ? self.refreshCount/_pageSize : 0;
    
    NSDictionary* params = @
    {
        @"requestParams" : _urlGenerator(_refreshName, pageIndex, _pageSize),
        @"pageIndex"    : [NSNumber numberWithInt:pageIndex],
        @"refreshName"  : _refreshName,
        @"needLoading"  : [NSNumber numberWithBool:_needLoading],
    };
    _needLoading = FALSE;   // Clean tag
    
    SEL handler = byFooter ? @selector(footRequestHandler:) : @selector(headRequestHandler:);
    _requester([self genDelegatorID:handler], !byFooter, params.wrapper);
}

- (void) onBeginRefreshingHeaderView
{
    [self requestData:FALSE];
   
    [self performSelector:@selector(endRefreshing:) withObject:_header afterDelay:2.0]; // Avoid request fail
}

- (void) headRequestHandler:(DotCDelegatorArguments*) arguments
{
    [self requestHandler:arguments byFooter:FALSE];
}

- (void) endRefreshing:(MJRefreshBaseView*)view
{
    //if([view isRefreshing])
    //{
        [view endRefreshing];
    //}
}

- (void) onBeginRefreshingFooterView
{
    [self requestData:TRUE];
    
    [self performSelector:@selector(endRefreshing:) withObject:_footer afterDelay:2.0]; // Avoid request fail
}

- (void) footRequestHandler:(DotCDelegatorArguments*) arguments
{
    [self requestHandler:arguments byFooter:TRUE];
}

- (void) requestHandler:(DotCDelegatorArguments*)arguments byFooter:(BOOL)byFooter
{
    MJRefreshBaseView* titileView = byFooter ? _footer : _header;
    
    DotCDictionaryWrapper* netData = [arguments getArgument:NET_ARGUMENT_RETOBJECT];
    
    if(_prevRequestHandler)
    {
        if(!_prevRequestHandler(self, !byFooter, arguments))
        {
            if(_onRequestDone)
            {
                _onRequestDone(self, !byFooter, netData);
            }
            return ;
        }
    }
    
    DotCDictionaryWrapper* mjData = _dataConverter(netData);
    
    if(!mjData)
    {
        goto OPERATION_DONE;
    }
    
    if(!byFooter)
    {
        assert([mjData getInt:@"pageIndex"] == 0);
        [_refreshData removeAllObjects];
    }
    
    NSArray* pageData = [mjData getArray:@"pageData"];
    _dataDone = pageData.count == 0;
    
    if(!_dataDone)
    {
        [_refreshData addObjectsFromArray:pageData];
        
        [_refreshView reloadData];
    }
    else if(byFooter)
    {
        [DotCHUDUtil showSuccessWithStatus:@"暂无更多数据"];
    }
    
OPERATION_DONE:
    [self endRefreshing:titileView];
    
    if(_postRequestHandler)
    {
        _postRequestHandler(self, !byFooter, arguments);
    }
    
    if(_onRequestDone)
    {
        _onRequestDone(self, !byFooter, netData);
    }
}

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if(refreshView == _header)
    {
        [self onBeginRefreshingHeaderView];
    }
    else if(refreshView == _footer)
    {
        [self onBeginRefreshingFooterView];
    }
}

- (NSArray*) refreshData
{
    return _refreshData;
}

- (int) refreshCount
{
    return (int)_refreshData.count;
}

- (id) dataAtIndex:(int)index
{
    if(index>= 0 && index<_refreshData.count)
    {
        id ret = [_refreshData objectAtIndex:index];
        
        if([ret isKindOfClass:[NSDictionary class]])
        {
            ret = ((NSDictionary*)ret).wrapper;
        }
        
        return ret;
    }
    
    return nil;
}

- (void) refresh
{
    assert(_refreshView);
    
    [self requestData:FALSE];
}

- (void) refreshWithLoading
{
    assert(_refreshView);
    _needLoading = TRUE;
    [self requestData:FALSE];
}

- (void) removeDataAtIndex:(int)index 
{
    if(index< 0 || index>=_refreshData.count)
    {
        return ;
    }

    [_refreshData removeObjectAtIndex:index];
}
- (void) removeDataAtIndex:(int)index andView:(UITableViewRowAnimation)animation
{
    if(index< 0 || index>=_refreshData.count)
    {
        return ;
    }
    
    [self removeDataAtIndex:index];
    [_refreshView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
                        withRowAnimation:animation];
}

+ (instancetype) controllerFrom:(UITableView*)refreshView name:(NSString*)refreshName
{
    assert(refreshView);
    
    MJRefreshController* ret = WEAK_OBJECT(self, initWithView:refreshView andName:refreshName);
    
    [ret addHeader];
    [ret addFooter];

    return ret;
}

+ (instancetype) controllerNoHeadersFrom:(UITableView*)refreshView name:(NSString*)refreshName
{
    assert(refreshView);
    
    MJRefreshController* ret = WEAK_OBJECT(self, initWithView:refreshView andName:refreshName);
    
    return ret;
}

#define SET_DEFAULT_BLOCK(name) [s_##name release];s_##name = [name copy];

+ (void) setDefaultURLGenerator:(MJRefreshURLGenerator) urlGenerator
{
    SET_DEFAULT_BLOCK(urlGenerator);
}

+ (void) setDefaultDataConverter:(MJRefreshNetData2MJData) dataConverter
{
    SET_DEFAULT_BLOCK(dataConverter);
}

+ (void) setDefaultRequester:(MJRefreshRequest)requester
{
    SET_DEFAULT_BLOCK(requester);
}

+ (void) setDefaultOnRequestDone:(MJRefreshOnRequestDone)onRequestDone
{
    SET_DEFAULT_BLOCK(onRequestDone);
}

+ (void) setDefaultPrevRequestHandler:(MJRefreshPrevRequestHandler)prevRequestHandler
{
    SET_DEFAULT_BLOCK(prevRequestHandler);
}

+ (void) setDefaultPostRequestHandler:(MJRefreshPostRequestHandler)postRequestHandler
{
    SET_DEFAULT_BLOCK(postRequestHandler);
}

+ (void) setDefaultHeaderContentViewClass:(Class)cls
{
    s_headerContentViewClass = cls;
}

#undef SET_DEFAULT_BLOCK

@end
