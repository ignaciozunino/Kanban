//
//  AddProjectViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNAddProjectViewController.h"
#import "KBNProjectTemplate.h"
#import "UITextView+CustomTextView.h"

@interface KBNAddProjectViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation KBNAddProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
    [self.descriptionTextView setBorderWithColor:[UIColorFromRGB(BORDER_GRAY) CGColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)save:(UIBarButtonItem *)sender {
    [KBNAppDelegate activateActivityIndicator:YES];
    __weak typeof(self) weakself = self;
    [[KBNProjectService sharedInstance] createProject:self.nameTextField.text withDescription:self.descriptionTextView.text forUser:[KBNUserUtils getUsername] withTemplate:self.selectedTemplate completionBlock:^(KBNProject *project) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:PROJECT_CREATION_SUCCESS andType:SUCCESS_ALERT];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PROJECT_ADDED object:project];
        [weakself.navigationController popToRootViewControllerAnimated:YES];

    } errorBlock:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
        [weakself.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];

}

@end
