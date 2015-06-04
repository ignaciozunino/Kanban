//
//  KBNReachabilityWidgetView.m
//  Kanban
//
//  Created by Marcelo Dessal on 6/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNReachabilityWidgetView.h"
#import "KBNReachabilityUtils.h"

@implementation KBNReachabilityWidgetView

// Called when loading programatically
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        // Call a common method to setup gesture and state of UIView
        [self setup];
    }
    return self;
}

// Called when loading from embedded .xib UIView
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Call a common method to setup gesture and state of UIView
        [self setup];
    }
    return self;
}

- (void)setup {
    
    // Set a rounded corner to the view
    self.layer.borderColor = [[UIColor redColor] CGColor];
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;
    
    
    UIImage *image = [self.cancelButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cancelButton setImage:image forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    
    [self setAlpha:0];
    
    // Subscribe to online notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:ONLINE object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showAnimated:(BOOL)animated {
    if (animated) {
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:0.5 animations:^{
            [weakself setAlpha:1];
        }];
    } else {
        [self setAlpha:1];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    if (animated) {
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:0.5 animations:^{
            [weakself setAlpha:0];
        }];
    } else {
        [self setAlpha:0];
    }
}

- (void)dismiss {
    [self dismissAnimated:YES];
}

@end
