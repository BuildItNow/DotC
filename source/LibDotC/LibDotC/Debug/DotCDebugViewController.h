//
//  DebugViewController.h

//
//  Created by Yang G on 14-6-25.
//  Copyright (c) 2014年 BIN . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DotCViewController.h"

@interface DotCDebugViewController : DotCViewController

@property (retain, nonatomic) IBOutlet UITextView *debugInfos;

- (void) appendLine:(NSString*)line;

- (void) shiftShow;

+ (instancetype) instance;

@end

#define DOTC_DEBUG_VIEW_CONTROLLER [DotCDebugViewController instance]
