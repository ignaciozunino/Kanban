//
//  KBNReachabilityWidgetView.h
//  Kanban
//
//  Created by Marcelo Dessal on 6/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNCustomViewFromXib.h"

@interface KBNReachabilityWidgetView : KBNCustomViewFromXib

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (void)showAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end
