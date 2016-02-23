//
//  HUDUtil.h
//  DotC
//
//  Created by Yang G on 14-7-2.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

typedef enum
{
    HUDMaskTypeNone = 1,
    HUDMaskTypeClear,
    HUDMaskTypeBlack,
    HUDMaskTypeGradient
}HUDMaskType;

@interface DotCHUDUtil : NSObject

+ (void) incNetLoading;
+ (void) decNetLoading;

+ (void)show;
+ (void)showWithMaskType:(HUDMaskType)maskType;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(HUDMaskType)maskType;

+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showImage:(UIImage*)image status:(NSString*)status;

+ (void)dismiss;

@end
