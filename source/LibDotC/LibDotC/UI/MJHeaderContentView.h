//
//  DotCHeaderContentView.h
//  LibDotC
//
//  Created by Yang G on 14-11-7.
//  Copyright (c) 2014年 DotC. All rights reserved.
//

#ifndef LibDotC_DotCHeaderContentView_h
#define LibDotC_DotCHeaderContentView_h

typedef enum {
    STATE_PULLING = 1,  // 松开就可以进行刷新的状态
    STATE_NORMAL ,      // 普通状态
    STATE_REFRESHING ,  // 正在刷新中的状态
    STATE_WILL_REFRESHING
} ERefreshState;

@protocol MJHeaderContentView <NSObject>
- (void)onSetState:(ERefreshState)state;
@optional
- (CGFloat)validY;
@end

#endif
