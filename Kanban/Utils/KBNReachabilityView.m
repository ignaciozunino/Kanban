//
//  KBNReachabilityView.m
//  Kanban
//
//  Created by Marcelo Dessal on 6/2/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNReachabilityView.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"

@implementation KBNReachabilityView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
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
}

- (void)cancel:(id)sender {
    [self setHidden:YES];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        [self removeFromSuperview];
    }
}

@end
