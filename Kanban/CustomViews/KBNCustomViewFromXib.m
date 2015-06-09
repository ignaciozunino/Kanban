//
//  KBNCustomViewFromXib.m
//  Kanban
//
//  Created by Marcelo Dessal on 6/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNCustomViewFromXib.h"

@implementation KBNCustomViewFromXib

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // 1. Load the .xib file (.xib file must match classname)
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Set the bounds if not set by programmer (i.e. init called)
        if(CGRectIsEmpty(frame)) {
            self.bounds = _customView.bounds;
        }
        
        // 3. Add as a subview
        [self addSubview:_customView];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        // 1. Load .xib file
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        
        // 2. Add as a subview
        [self addSubview:_customView];
        
    }
    return self;
}

@end
