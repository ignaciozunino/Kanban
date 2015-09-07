//
//  AddTaskViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNAddTaskViewController.h"
#import "KBNConstants.h"
#import "KBNAlertUtils.h"
#import "KBNTaskService.h"
#import "UITextView+CustomTextView.h"
#import "KBNReachabilityWidgetView.h"
#import "KBNReachabilityUtils.h"
#import "KBNTaskPriorityPickerView.h"

@interface KBNAddTaskViewController (){
        NSUInteger prioritySelected;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet KBNReachabilityWidgetView *reachabilityView;
@property (weak, nonatomic) IBOutlet UIView *viewPickerView;
@property (weak, nonatomic) IBOutlet KBNTaskPriorityPickerView *priorityPickerView;
@property (weak, nonatomic) IBOutlet UIButton *priorityButton;
@property (weak, nonatomic) IBOutlet UILabel *priorityColor;

@property (strong, nonatomic) MBProgressHUD* HUD;
@property (strong, nonatomic) NSMutableArray *priorityData;

@end

@implementation KBNAddTaskViewController

@synthesize priorityPickerView;
@synthesize priorityData;
@synthesize viewPickerView;
@synthesize priorityColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
    [self.descriptionTextView setBorderWithColor:[UIColorFromRGB(BORDER_GRAY) CGColor]];
    
    prioritySelected = 2;
    
    priorityData = [[NSMutableArray alloc] init];
    
    [priorityData addObject:PRIORITY_HIGH];
    [priorityData addObject:PRIORITY_MEDIUM];
    [priorityData addObject:PRIORITY_LOW];
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float pickerWidth = screenWidth;
    float pickerHeight = 162.0;
    float toolBarHeight = 44;
    
    
    [priorityPickerView setDelegate:self];
    [priorityPickerView setDataSource:self];
    
    [viewPickerView setFrame:CGRectMake(0.0, screenHeight + 1, pickerWidth, pickerHeight)];
    [priorityPickerView setFrame:CGRectMake(0.0, 30, pickerWidth, pickerHeight - toolBarHeight)];
    
    viewPickerView.alpha = 0;
    priorityPickerView.userInteractionEnabled = NO;
    priorityPickerView.showsSelectionIndicator = YES;
    [priorityPickerView setBackgroundColor:[UIColor whiteColor]];
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,pickerWidth,toolBarHeight)];
    toolBar.barTintColor = [UIColor whiteColor];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:DONE_TITLE
                                                                      style:UIBarButtonItemStyleBordered target:self action:@selector(donePickerView:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:flexibleSpace, barButtonDone, nil]];
    
    barButtonDone.tintColor=self.view.tintColor;
    toolBar.userInteractionEnabled = YES;
    barButtonDone.enabled =YES;
    
    [viewPickerView addSubview:toolBar];
    [viewPickerView addSubview:priorityPickerView];
    
    [priorityPickerView initialConfigurationWithPriority:prioritySelected onView:viewPickerView withPriorityButton:self.priorityButton withPriorityColor:priorityColor];
    
    [self.priorityButton setTitle:PRIORITY_LOW forState:UIControlStateNormal];
    [self.priorityPickerView selectRow:prioritySelected inComponent:0 animated:NO];

    [self.view addSubview:viewPickerView];
}

-(void)donePickerView:(id)sender{
    if (priorityPickerView.userInteractionEnabled) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6];
        CGAffineTransform transfrom;
        transfrom = CGAffineTransformMakeTranslation(0, 0);
        priorityPickerView.userInteractionEnabled = !priorityPickerView.userInteractionEnabled;
        
        viewPickerView.transform = transfrom;
        viewPickerView.alpha = viewPickerView.alpha * (-1) + 1;
        [UIView commitAnimations];
    }
}

-(IBAction)priorityTapped:(id)sender{
    
    if (!priorityPickerView.userInteractionEnabled) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6];
        CGAffineTransform transfrom;
        transfrom = CGAffineTransformMakeTranslation(0, -162.0);
        priorityPickerView.userInteractionEnabled = !priorityPickerView.userInteractionEnabled;
        
        viewPickerView.transform = transfrom;
        viewPickerView.alpha = viewPickerView.alpha * (-1) + 1;
        [UIView commitAnimations];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)save:(UIBarButtonItem *)sender {
    
    [self.view endEditing:YES];
    [self startHUD];

    self.addTask.name = self.nameTextField.text;
    self.addTask.taskDescription = self.descriptionTextView.text;
    prioritySelected = priorityPickerView.prioritySelected;
    self.addTask.priority = [NSNumber numberWithInteger:prioritySelected];
    
    __weak typeof(self) weakself = self;
    [[KBNTaskService sharedInstance] createTask:self.addTask inList:self.addTask.taskList completionBlock:^(KBNTask *task) {
        [weakself.delegate didCreateTask:task];
        [self dismissViewControllerAnimated:YES completion:nil];
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - HUD

- (void)startHUD {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.HUD.dimBackground = YES;
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    self.HUD.labelText = ADD_TASK_LOADING;
    [self.HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    self.HUD.delegate = self;
}

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.05f;
        self.HUD.progress = progress;
        usleep(50000);
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
    prioritySelected = row;
    [self.priorityButton setTitle:[priorityData objectAtIndex:row] forState:UIControlStateNormal];
    switch (row) {
        case 0:
        [priorityColor setBackgroundColor:HIGH_COLOR];
        break;
        case 1:
        [priorityColor setBackgroundColor:MEDIUM_COLOR];
        break;
        case 2:
        [priorityColor setBackgroundColor:LOW_COLOR];
        break;
    }
}

@end
