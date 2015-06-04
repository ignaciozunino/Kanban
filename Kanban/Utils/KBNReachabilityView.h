//
//  KBNReachabilityView.h
//  Kanban
//
//  Created by Marcelo Dessal on 6/2/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBNReachabilityView : UIView

+ (instancetype)sharedView;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)moveOnRotation;

@end
