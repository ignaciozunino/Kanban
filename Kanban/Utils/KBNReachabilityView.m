//
//  KBNReachabilityView.m
//  Kanban
//
//  Created by Marcelo Dessal on 6/2/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNReachabilityView.h"
#import "KBNReachabilityUtils.h"
#import "KBNConstants.h"

@implementation KBNReachabilityView

+ (instancetype) sharedView {
    static dispatch_once_t onceToken = 0;
    __strong static id _sharedObject = nil;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    CGRect frame = CGRectMake(screenWidth / 2 - 150, screenHeight - 54, 300, 46);
    
    dispatch_once(&onceToken, ^{
        if (!_sharedObject) {
            _sharedObject = [[self alloc] initWithFrame:frame];
            [_sharedObject baseInit];
        }
    });
    
    return _sharedObject;
}

- (void)baseInit {
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(4, 4, width, height - 8)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width - 38, 8, 30, 30)];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    [textfield setLeftView:spacerView];
    
    textfield.text = OFFLINE_WARNING;
    textfield.font = [UIFont fontWithName:@"Helvetica" size:15];
    [textfield setTextColor:[UIColor redColor]];
    [textfield setEnabled:NO];
    
    textfield.layer.borderColor = [[UIColor redColor] CGColor];
    textfield.layer.borderWidth = 1.0;
    textfield.layer.cornerRadius = 5.0;
    textfield.layer.masksToBounds = YES;
    [self addSubview:textfield];
    
    UIImage *image = [[UIImage imageNamed:@"cancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = [UIColor redColor];
    [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:button];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAlpha:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancel:) name:ONLINE object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cancel:(id)sender {
    [self setHidden:YES animated:YES];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    
    if (animated) {
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:0.5 animations:^{
            hidden?[weakself setAlpha:0]:[weakself setAlpha:1];
        } completion:^(BOOL finished) {
            if (hidden) {
                [weakself removeFromSuperview];
            }
        }];
    }
}

- (void)moveOnRotation {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = self.frame;
    frame.origin.x = (screenRect.size.width - frame.size.width) / 2;
    frame.origin.y = screenRect.size.height - frame.size.height - 8;
    [self setFrame:frame];
}

@end
