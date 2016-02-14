//
//  DebugViewController.m

//
//  Created by Yang G on 14-6-25.
//  Copyright (c) 2014年 BIN. All rights reserved.
//

#import "DotCDebugViewController.h"

const int MAX_LINES = 512;

@interface DotCDebugViewController ()
{
    BOOL             _visible;
    BOOL             _editable;
}

@end

@implementation DotCDebugViewController

- (void) dealloc
{
    [_debugInfos release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _visible = FALSE;
    _editable = FALSE;
}

- (void)viewDidUnload {
    [self setDebugInfos:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) appendLine:(NSString*)line
{
    NSString* text = [_debugInfos.text stringByAppendingFormat:@"\n%@", line];
    _debugInfos.text = text;
    if(text.length)
    {
        NSRange range;
        range.length   = 1;
        range.location = text.length-1;
        [_debugInfos scrollRangeToVisible:range];
    }
}

- (void) shiftShow
{
    if(_visible)
    {
        [self.view removeFromSuperview];
    }
    else
    {
        [DOTC_DELEGATE.window addSubview:self.view];
        _editable = !_editable;
        self.view.userInteractionEnabled = _editable;
    }
    _visible = !_visible;
}

- (void) onShaked:(NSNotification*)notification
{
    [self shiftShow];
}

- (IBAction)onClean
{
    _debugInfos.text = @"";
}

+ (instancetype) instance
{
    static DotCDebugViewController* s_instance = nil;
    if(!s_instance)
    {
        s_instance = STRONG_OBJECT(DotCDebugViewController, initWithNibName:@"DebugViewController" bundle:nil);
        
        [[NSNotificationCenter defaultCenter] addObserver:s_instance selector:@selector(onShaked:) name:@"shake_event" object:nil];
    }
    
    return s_instance;
}
@end
