//
//  KBNTaskPriorityPickerView.h
//  Kanban
//
//  Created by guerrier on 30/07/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBNTaskPriorityPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSUInteger prioritySelected;

-(void) initialConfigurationWithPriority: (NSUInteger) priority onView:(UIView *) viewPickerView withPriorityButton:(UIButton *) priorityButton withPriorityColor: (UILabel *) priorityColor;

@end
