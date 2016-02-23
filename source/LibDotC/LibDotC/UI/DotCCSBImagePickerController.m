//
//  CSBImagePickerController.m

//
//  Created by Yang G on 14-6-20.
//  Copyright (c) 2014年 .C . All rights reserved.
//

#import "DotCCSBImagePickerController.h"

#import <objc/objc.h>
#import <objc/runtime.h>

@interface NSObject (RuntimeClass)

- (id) getIvarValue:(const char*)ivarName;

- (void) setIvarValue:(const char*)ivarName value:(id)value;

@end

@implementation NSObject (RuntimeClass)

- (id) getIvarValue:(const char*)ivarName
{
    void* outValue = NULL;
    
    if(!object_getInstanceVariable(self, ivarName, &outValue))
    {
        NSLog(@"getIvarValue %s fail", ivarName);
    }
    
    NSLog(@"getIvarValue %p", outValue);
    
    return (id)outValue;
}

- (void) setIvarValue:(const char*)ivarName value:(id)value
{
    if(!object_setInstanceVariable(self, ivarName, (void*)value))
    {
        NSLog(@"setIvarValue %s fail", ivarName);
    }
    
    NSLog(@"setIvarValue %p", value);
}

- (void) releaseIvar:(const char*)ivarName
{
    [[self getIvarValue:ivarName] release];
}

- (void) autoreleaseIvar:(const char*)ivarName
{
    [[self getIvarValue:ivarName] autorelease];
}

- (void) releaseIvarWithNil:(const char*)ivarName
{
    [[self getIvarValue:ivarName] release];
    [self setIvarValue:ivarName value:nil];
}

- (void) autoreleaseIvarWithNil:(const char*)ivarName
{
    [[self getIvarValue:ivarName] autorelease];
    [self setIvarValue:ivarName value:nil];
}

@end


typedef id<UINavigationControllerDelegate, UIImagePickerControllerDelegate> ImplDelegate;

@interface DotCCSBImagePickerController ()
{
    UIStatusBarStyle    _csbStyle;
    ImplDelegate        _implDelegate;
}

@end

@implementation DotCCSBImagePickerController

- (id)init
{
    self = [super init];
    if(self)
    {
        _csbStyle = UIStatusBarStyleDefault;
    }
    
    return self;
}

- (void)setImplDelegate:(ImplDelegate)implDelegate
{
    _implDelegate = implDelegate;
}

- (ImplDelegate)implDelegate
{
    return _implDelegate;
}

- (void)setCsbStyle:(UIStatusBarStyle)csbStyle
{
    _csbStyle = csbStyle;
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:_csbStyle animated:NO];
    
    if([_implDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
    {
        [_implDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

void navigationControllerDidShowViewControllerAnimated(id self, SEL cmd, UINavigationController* navigationController, UIViewController* viewController, BOOL animated)
{
    ImplDelegate _implDelegate = [self implDelegate];
    
    APP_ASSERT([_implDelegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]);
    
   [_implDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
}

NSUInteger navigationControllerSupportedInterfaceOrientations(id self, SEL cmd, UINavigationController* navigationController) // NS_AVAILABLE_IOS(7_0)
{
    ImplDelegate _implDelegate = [self implDelegate];
    
    APP_ASSERT([_implDelegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]);
    
    return [_implDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
}

UIInterfaceOrientation navigationControllerPreferredInterfaceOrientationForPresentation(id self, SEL cmd, UINavigationController* navigationController) // NS_AVAILABLE_IOS(7_0)
{
    ImplDelegate _implDelegate = [self implDelegate];
    
    APP_ASSERT([_implDelegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]);
    
    return [_implDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
}

id <UIViewControllerInteractiveTransitioning> navigationControllerInteractionControllerForAnimationController(id self, SEL cmd,
                                                                                                              UINavigationController* navigationController,
                                                                                                              id <UIViewControllerAnimatedTransitioning> animationController) // NS_AVAILABLE_IOS(7_0)
{
    ImplDelegate _implDelegate = [self implDelegate];

    APP_ASSERT([_implDelegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]);
    
    return [_implDelegate navigationController:navigationController interactionControllerForAnimationController:animationController];
}

id <UIViewControllerAnimatedTransitioning> navigationControllerAnimationControllerForOperationFromViewControllerToViewController(id self, SEL cmd,
                                                                                                                                UINavigationController* navigationController,
                                                                                                                                 UINavigationControllerOperation operation,
                                                                                                                                 UIViewController* fromVC,
                                                                                                                                 UIViewController* toVC) //  NS_AVAILABLE_IOS(7_0)
{
    ImplDelegate _implDelegate = [self implDelegate];
    
    APP_ASSERT([_implDelegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]);
    
    return [_implDelegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
}

#pragma mark UIImagePickerControllerDelegate delegate
void imagePickerControllerDidFinishPickingImageEditingInfo(id self, SEL cmd, UIImagePickerController* picker, UIImage* image, NSDictionary* editingInfo) // NS_DEPRECATED_IOS(2_0, 3_0)
{
    ImplDelegate _implDelegate = [self implDelegate];
    
    APP_ASSERT([_implDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImage:editingInfo:)]);

    [_implDelegate imagePickerController:picker didFinishPickingImage:image editingInfo:editingInfo];
}

void imagePickerControllerDidFinishPickingMediaWithInfo(id self, SEL cmd, UIImagePickerController* picker, NSDictionary* info)
{
    ImplDelegate _implDelegate = [self implDelegate];
    
    APP_ASSERT([_implDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]);
    
    [_implDelegate imagePickerController:picker didFinishPickingMediaWithInfo:info];
}

void imagePickerControllerDidCancel(id self, SEL cmd, UIImagePickerController* picker)
{
    ImplDelegate _implDelegate = [self implDelegate];
    
    APP_ASSERT([_implDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]);
    
    [_implDelegate imagePickerControllerDidCancel:picker];
}

//static const char* avar(const char* fmt, ...)
//{
//    static char szBuffer[128] = {0};
//    va_list va;
//    va_start(va, fmt);
//    
//    vsprintf(szBuffer, fmt, va);
//    
//    va_end(va);
//
//    return szBuffer;
//}

#define ENCODE_0(ret) [NSString stringWithFormat:@"%s@:", @encode(ret)]
#define ENCODE_1(ret, arg0) [NSString stringWithFormat:@"%s@:%s", @encode(ret), @encode(arg0)]
#define ENCODE_2(ret, arg0, arg1) [NSString stringWithFormat:@"%s@:%s%s", @encode(ret), @encode(arg0), @encode(arg1)]
#define ENCODE_3(ret, arg0, arg1, arg2) [NSString stringWithFormat:@"%s@:%s%s%s", @encode(ret), @encode(arg0), @encode(arg1), @encode(arg2)]
#define ENCODE_4(ret, arg0, arg1, arg2, arg3) [NSString stringWithFormat:@"%s@:%s%s%s%s", @encode(ret), @encode(arg0), @encode(arg1), @encode(arg2), @encode(arg3)]

enum EMask
{
    EnavigationControllerDidShowViewControllerAnimated  = BIT(0),
    EnavigationControllerSupportedInterfaceOrientations = BIT(1),
    EnavigationControllerPreferredInterfaceOrientationForPresentation = BIT(2),
    EnavigationControllerInteractionControllerForAnimationController = BIT(3),
    EnavigationControllerAnimationControllerForOperationFromViewControllerToViewController = BIT(4),
    EimagePickerControllerDidFinishPickingImageEditingInfo = BIT(5),
    EimagePickerControllerDidFinishPickingMediaWithInfo = BIT(6),
    EimagePickerControllerDidCancel = BIT(7),
};

Class controllerClass(ImplDelegate delegate)
{
    typedef struct
    {
        SEL             selector;
        int             mask;
        IMP             imp;
        NSString*       types;
    }SItem;
    
    SItem items[] =
    {
        {   @selector(navigationController:didShowViewController:animated:),
            EnavigationControllerDidShowViewControllerAnimated,
            (IMP)navigationControllerDidShowViewControllerAnimated,
            ENCODE_3(void, UINavigationController*, UIViewController*, BOOL)
        },
        {
            @selector(navigationControllerSupportedInterfaceOrientations:),
            EnavigationControllerSupportedInterfaceOrientations,
            (IMP)navigationControllerSupportedInterfaceOrientations,
            ENCODE_1(NSInteger, UINavigationController*)
        },
        {
            @selector(navigationControllerPreferredInterfaceOrientationForPresentation:),
            EnavigationControllerPreferredInterfaceOrientationForPresentation,
            (IMP)navigationControllerPreferredInterfaceOrientationForPresentation,
            ENCODE_1(UIInterfaceOrientation, UINavigationController*)
        },
        {
            @selector(navigationController:interactionControllerForAnimationController:),
            EnavigationControllerInteractionControllerForAnimationController,
            (IMP)navigationControllerInteractionControllerForAnimationController,
            ENCODE_2(id <UIViewControllerInteractiveTransitioning>, UINavigationController*, id<UIViewControllerAnimatedTransitioning>)

        },
        {
            @selector(navigationController:animationControllerForOperation:fromViewController:toViewController:),
            EnavigationControllerAnimationControllerForOperationFromViewControllerToViewController,
            (IMP)navigationControllerAnimationControllerForOperationFromViewControllerToViewController,
            ENCODE_4(id <UIViewControllerAnimatedTransitioning>, UINavigationController*, UINavigationControllerOperation, UIViewController*, UIViewController*)
        },
        {
            @selector(imagePickerController:didFinishPickingImage:editingInfo:),
            EimagePickerControllerDidFinishPickingImageEditingInfo,
            (IMP)imagePickerControllerDidFinishPickingImageEditingInfo,
            ENCODE_3(void, UIImagePickerController*, UIImage*, NSDictionary*)
        },
        {
            @selector(imagePickerController:didFinishPickingMediaWithInfo:),
            EimagePickerControllerDidFinishPickingMediaWithInfo,
            (IMP)imagePickerControllerDidFinishPickingMediaWithInfo,
            ENCODE_2(void, UIImagePickerController*, NSDictionary*)
        },
        {
            @selector(imagePickerControllerDidCancel:),
            EimagePickerControllerDidCancel,
            (IMP)imagePickerControllerDidCancel,
            ENCODE_1(void, UIImagePickerController*)
        }
    };
    
    int mask  = 0;
    
    SItem* pos = items;
    SItem* end = pos+COUNT_OF(items);
    
    for(; pos!=end; ++pos)
    {
        if([delegate respondsToSelector:pos->selector])
        {
            mask |= pos->mask;
        }
    }
    
    static NSMutableDictionary* s_classes = nil;
    if(!s_classes)
    {
        s_classes = STRONG_OBJECT(NSMutableDictionary, init);
    }
    
    NSNumber* key = [NSNumber numberWithInt:mask];
    Class class = [s_classes objectForKey:key];
    if(!class)
    {
        NSString* className = [NSString stringWithFormat:@"CSBImagePickerController_%d", mask];
        class = objc_allocateClassPair([DotCCSBImagePickerController class], [className cStringUsingEncoding:NSASCIIStringEncoding], 0);
        if(!class)
        {
            NSLog(@"controllerClass fail");
            return nil;
        }
        
        pos = items;
        for(; pos!=end; ++pos)
        {
            if(mask & pos->mask)
            {
                class_addMethod(class, pos->selector, pos->imp, [pos->types cStringUsingEncoding:NSASCIIStringEncoding]);
            }
        }
        
        objc_registerClassPair(class);
        
        [s_classes setObject:class forKey:key];
    }
    
    return class;
}

+ (instancetype) controllerFrom:(ImplDelegate) delegate csbStyle:(UIStatusBarStyle) csbStyle
{
    DotCCSBImagePickerController* controller = WEAK_OBJECT(controllerClass(delegate), init);
    controller.delegate = controller;
    controller.implDelegate = delegate;
    controller.csbStyle = csbStyle;
    
    return controller;
}

@end
