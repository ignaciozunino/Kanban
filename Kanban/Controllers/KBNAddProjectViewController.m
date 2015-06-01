//
//  AddProjectViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNAddProjectViewController.h"
#import "UITextView+CustomTextView.h"

@interface KBNAddProjectViewController () <MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property MBProgressHUD* HUD;

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

- (void)startHUD {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.HUD.dimBackground = YES;
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    self.HUD.labelText = @"Creating the project";
    [self.HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    self.HUD.delegate = self;
}

#pragma mark - IBActions

- (IBAction)save:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self startHUD];
    [KBNAppDelegate activateActivityIndicator:YES];
    __weak typeof(self) weakself = self;
    [self.projectService createProject:self.nameTextField.text withDescription:self.descriptionTextView.text forUser:[KBNUserUtils getUsername] completionBlock:^(KBNProject *project) {
        [KBNAppDelegate activateActivityIndicator:NO];
        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        self.HUD.mode = MBProgressHUDModeCustomView;

        [weakself.delegate didCreateProject:project];
        sleep(1);
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

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.040f;
        self.HUD.progress = progress;
        usleep(50000);
    }
}

@end
