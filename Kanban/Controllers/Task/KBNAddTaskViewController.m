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

@end

@implementation KBNAddTaskViewController

@synthesize priorityPickerView;
@synthesize viewPickerView;
@synthesize priorityColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
    [self.descriptionTextView setBorderWithColor:[UIColorFromRGB(BORDER_GRAY) CGColor]];
    
    prioritySelected = 2;
    
    [priorityPickerView initialConfigurationWithPriority:prioritySelected onView:viewPickerView withPriorityButton:self.priorityButton withPriorityColor:priorityColor];
    
    [self.priorityButton setTitle:PRIORITY_LOW forState:UIControlStateNormal];
    [self.view addSubview:viewPickerView];
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

-(IBAction)priorityTapped:(id)sender{
    
    if (!priorityPickerView.userInteractionEnabled) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6];
        CGAffineTransform transfrom;
        transfrom = CGAffineTransformMakeTranslation(0, -162.0);
        priorityPickerView.userInteractionEnabled = !priorityPickerView.userInteractionEnabled;
        
        self.viewPickerView.transform = transfrom;
        self.viewPickerView.alpha = self.viewPickerView.alpha * (-1) + 1;
        [UIView commitAnimations];
    }
    
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

@end
