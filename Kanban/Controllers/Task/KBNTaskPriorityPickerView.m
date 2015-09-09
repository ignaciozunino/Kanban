//
//  KBNTaskPriorityPickerView.m
//  Kanban
//
//  Created by guerrier on 30/07/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskPriorityPickerView.h"
#import "KBNConstants.h"

#define pickerHeight 162.0
#define toolBarHeight 44.0

@interface KBNTaskPriorityPickerView()

@property (strong, nonatomic) NSMutableArray *priorityData;
@property (weak, nonatomic) UIView *viewPickerView;
@property (weak, nonatomic) UIButton *priorityButton;
@property (weak, nonatomic) UILabel *priorityColor;

@end

@implementation KBNTaskPriorityPickerView

@synthesize priorityData;
@synthesize prioritySelected;

-(void) initialConfigurationWithPriority: (PriorityState) priority onView:(UIView *) viewPickerView withPriorityButton:(UIButton *) priorityButton withPriorityColor: (UILabel *) priorityColor{
    prioritySelected = priority;
    self.viewPickerView = viewPickerView;
    self.priorityButton = priorityButton;
    self.priorityColor = priorityColor;
    priorityData = [[NSMutableArray alloc] init];
    
    [priorityData addObject:PRIORITY_HIGH];
    [priorityData addObject:PRIORITY_MEDIUM];
    [priorityData addObject:PRIORITY_LOW];
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float pickerWidth = screenWidth;
    
    
    [self setDelegate:self];
    [self setDataSource:self];
    
    [viewPickerView setFrame:CGRectMake(0.0, screenHeight + 1, pickerWidth, pickerHeight)];
    [self setFrame:CGRectMake(0.0, 30, pickerWidth, pickerHeight - toolBarHeight)];
    
    viewPickerView.alpha = 0;
    self.userInteractionEnabled = NO;
    self.showsSelectionIndicator = YES;
    [self setBackgroundColor:[UIColor whiteColor]];
    
     UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,pickerWidth,toolBarHeight)];
    toolBar.barTintColor = [UIColor whiteColor];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:DONE_TITLE
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(donePickerView:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:flexibleSpace, barButtonDone, nil]];
    
    barButtonDone.tintColor=viewPickerView.tintColor;
    toolBar.userInteractionEnabled = YES;
    barButtonDone.enabled =YES;
    
    [viewPickerView addSubview:toolBar];
    [viewPickerView addSubview:self];
    
    [self selectRow:prioritySelected inComponent:0 animated:NO];
}

-(void)donePickerView:(id)sender{
    if (self.userInteractionEnabled) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6];
        CGAffineTransform transfrom;
        transfrom = CGAffineTransformMakeTranslation(0, 0);
        self.userInteractionEnabled = !self.userInteractionEnabled;
        
        self.viewPickerView.transform = transfrom;
        self.viewPickerView.alpha = self.viewPickerView.alpha * (-1) + 1;
        [UIView commitAnimations];
    }
}

#pragma mark - UIPickereViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [priorityData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [priorityData objectAtIndex:row];
}

#pragma mark - UIPickerViewDelegate
-(void) pickerView:pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    prioritySelected = (PriorityState)row;
    [self.priorityButton setTitle:[priorityData objectAtIndex:row] forState:UIControlStateNormal];
    switch (row) {
        case PRIORITYSTATE_HIGH:
            [self.priorityColor setBackgroundColor:HIGH_COLOR];
            break;
        case PRIORITYSTATE_MEDIUM:
            [self.priorityColor setBackgroundColor:MEDIUM_COLOR];
            break;
        case PRIORITYSTATE_LOW:
            [self.priorityColor setBackgroundColor:LOW_COLOR];
            break;
    }
}

@end
