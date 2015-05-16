//
//  UITextView+CustomTextView.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "UITextView+CustomTextView.h"

@implementation UITextView (CustomTextView)

- (void)setBorder {
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 6.0f;
    self.layer.masksToBounds = YES;
}

- (void)setBorderWithColor:(CGColorRef)color {
    [self setBorder];
    self.layer.borderColor = color;
}



@end
