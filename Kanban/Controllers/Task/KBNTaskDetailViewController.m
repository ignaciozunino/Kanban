//
//  TaskDetailViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskDetailViewController.h"
#import "KBNTaskPriorityPickerView.h"

@interface KBNTaskDetailViewController (){
    NSUInteger prioritySelected;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIView *viewPickerView;
@property (weak, nonatomic) IBOutlet KBNTaskPriorityPickerView *priorityPickerView;
@property (weak, nonatomic) IBOutlet UIButton *priorityButton;
@property (weak, nonatomic) IBOutlet UILabel *priorityColor;

@property UIBarButtonItem *editButton;
@property UIBarButtonItem *saveButton;
@property (strong, nonatomic) NSMutableArray *priorityData;

@property BOOL isEditing;

@end

@implementation KBNTaskDetailViewController

@synthesize priorityPickerView;
@synthesize priorityData;
@synthesize viewPickerView;
@synthesize priorityColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                    target:self
                                                                    action:@selector(onEditPressed:)];
    self.saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onSavePressed:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    [priorityPickerView initialConfigurationWithPriority:prioritySelected onView:viewPickerView withPriorityButton:self.priorityButton withPriorityColor:priorityColor];
    
    [self.view addSubview:viewPickerView];
}

- (void)setUpView {
    self.isEditing = NO;
    self.title = self.task.project.name;
    self.nameTextField.text = self.task.name;
    self.descriptionTextField.text = self.task.taskDescription;
    prioritySelected = [self.task.priority integerValue];
    switch (prioritySelected) {
        case 0:
            [self.priorityButton setTitle:PRIORITY_HIGH forState:UIControlStateNormal];
            [priorityColor setBackgroundColor:HIGH_COLOR];
            break;
        case 1:
            [self.priorityButton setTitle:PRIORITY_MEDIUM forState:UIControlStateNormal];
            [priorityColor setBackgroundColor:MEDIUM_COLOR];
            break;
        case 2:
            [self.priorityButton setTitle:PRIORITY_LOW forState:UIControlStateNormal];
            [priorityColor setBackgroundColor:LOW_COLOR];
            break;
    }
    [self setUpEditingState];
}
- (void)setUpEditingState {
    if (self.isEditing) {
        self.nameTextField.enabled = YES;
        self.descriptionTextField.editable = YES;
        self.navigationItem.rightBarButtonItem = self.saveButton;
        self.priorityButton.enabled = YES;
        [self.nameTextField becomeFirstResponder];
    }else{
        self.nameTextField.enabled = NO;
        self.descriptionTextField.editable = NO;
        self.priorityButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = self.editButton;
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

- (IBAction)onEditPressed:(id)sender {
    self.isEditing = !self.isEditing;
    [self setUpEditingState];
}

- (IBAction)onSavePressed:(id)sender {
    self.task.name = self.nameTextField.text;
    self.task.taskDescription = self.descriptionTextField.text;
    prioritySelected = priorityPickerView.prioritySelected;
    self.task.priority = [NSNumber numberWithInteger:prioritySelected];
    [[KBNTaskService sharedInstance] updateTask:self.task onSuccess:^{
        [KBNAlertUtils showAlertView:TASK_EDIT_SUCCESS andType:SUCCESS_ALERT];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
    }];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
