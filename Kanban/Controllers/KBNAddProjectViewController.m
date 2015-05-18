//
//  AddProjectViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNAddProjectViewController.h"
#import "UITextView+CustomTextView.h"

@interface KBNAddProjectViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation KBNAddProjectViewController

@synthesize delegate;

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

- (instancetype)initWithService:(KBNProjectService *) projectService{
    
    self = [super init];
    
    if (self) {
        _projectService = projectService;
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)save:(UIBarButtonItem *)sender {
    [KBNAppDelegate activateActivityIndicator:YES];
    __weak typeof(self) weakself = self;
    [self.projectService createProject:self.nameTextField.text withDescription:self.descriptionTextView.text forUser:[KBNUserUtils getUsername] completionBlock:^(KBNProject *project) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:PROJECT_CREATION_SUCCESS andType:SUCCESS_ALERT];
        
        [weakself.delegate didCreateProject:project];
        [weakself dismissViewControllerAnimated:YES completion:nil];
        
    } errorBlock:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
