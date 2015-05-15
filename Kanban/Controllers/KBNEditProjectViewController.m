//
//  EditProjectViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEditProjectViewController.h"
#import "UITextView+CustomTextView.h"

#define TABLEVIEW_TASKLIST_CELL @"stateCell"

@interface KBNEditProjectViewController()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end


@implementation KBNEditProjectViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadProjectAttributes];
    self.navigationItem.title = @"Edit Project";
    
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
    [self.descriptionTextView setBorderWithColor:[UIColorFromRGB(BORDER_GRAY) CGColor]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)loadProjectAttributes {
    self.nameTextField.text = self.project.name;
    self.descriptionTextView.text = self.project.projectDescription;
}

#pragma mark - IBActions

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onCancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)onSavePressed:(id)sender {
    [KBNAppDelegate activateActivityIndicator:YES];
    [[KBNProjectService sharedInstance] editProject:self.project.projectId withNewName:self.nameTextField.text withDescription:self.descriptionTextView.text completionBlock:^{
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:PROJECT_EDIT_SUCCESS andType:SUCCESS_ALERT];
        [self dismissViewControllerAnimated:YES completion:nil];

    } errorBlock:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
