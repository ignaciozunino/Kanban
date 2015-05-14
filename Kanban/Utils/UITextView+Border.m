//
//  UITextView+Border.m
//  MyMoviesApp
//
//  Created by Marcelo Dessal on 3/11/15.
//  Copyright (c) 2015 Marcelo Dessal. All rights reserved.
//

#import "UITextView+Border.h"

@implementation UITextView (Border)

- (void)setBorder {
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 8.0f;
    self.layer.masksToBounds = YES;
}

- (void)setBorderWithColor:(CGColorRef)color {
    [self setBorder];
    self.layer.borderColor = color;
}

@end
