//
//  TaskDetailViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTaskDetailViewController.h"

@interface KBNTaskDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property UIBarButtonItem *editButton;
@property UIBarButtonItem *saveButton;

@property BOOL isEditing;

@end

@implementation KBNTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                    target:self
                                                                    action:@selector(onEditPressed:)];
    self.saveButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onSavePressed:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
}

- (void)setUpView {
    self.isEditing = NO;
    self.title = self.task.project.name;
    self.nameTextField.text = self.task.name;
    self.descriptionTextField.text = self.task.taskDescription;
    [self setUpEditingState];
}
- (void)setUpEditingState {
    if (self.isEditing) {
        self.nameTextField.enabled = YES;
        self.descriptionTextField.editable = YES;
        self.navigationItem.rightBarButtonItem = self.saveButton;
        [self.nameTextField becomeFirstResponder];
    }else{
        self.nameTextField.enabled = NO;
        self.descriptionTextField.editable = NO;
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
}

- (IBAction)onEditPressed:(id)sender {
    self.isEditing = !self.isEditing;
    [self setUpEditingState];
}

- (IBAction)onSavePressed:(id)sender {
    self.task.name = self.nameTextField.text;
    self.task.taskDescription = self.descriptionTextField.text;
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
