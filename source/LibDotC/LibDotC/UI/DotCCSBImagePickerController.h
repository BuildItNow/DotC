//
//  CSBImagePickerController.h

//
//  Created by Yang G on 14-6-20.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DotCCSBImagePickerController : UIImagePickerController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (instancetype) controllerFrom:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>) delegate csbStyle:(UIStatusBarStyle) csbStyle;

@end
