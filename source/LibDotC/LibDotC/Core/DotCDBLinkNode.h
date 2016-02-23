//
//  DBLinkNode.h

//
//  Created by Yang G on 14-7-16.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DotCDBLinkNode : NSObject

- (id) value;
- (DotCDBLinkNode*) prev;
- (DotCDBLinkNode*) next;
- (void) setValue:(id)value;
- (void) linkBefore:(DotCDBLinkNode*)listNode;
- (void) linkAfter:(DotCDBLinkNode*)listNode;
- (void) unLink;

+ (instancetype) nodeFrom:(id)value;

@end


