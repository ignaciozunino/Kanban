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
#import "KBNReachabilityUtils.h"
#import "KBNReachabilityWidgetView.h"

@interface KBNAddProjectViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet KBNReachabilityWidgetView *reachabilityView;

@property (strong, nonatomic) MBProgressHUD* HUD;

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
    
    if ([KBNReachabilityUtils isOffline]) {
        [self.reachabilityView showAnimated:YES];
        return;
    }

    [self.view endEditing:YES];
    [self startHUD];
    __weak typeof(self) weakself = self;
    [[KBNProjectService sharedInstance] createProject:self.nameTextField.text withDescription:self.descriptionTextView.text withTemplate:self.selectedTemplate completionBlock:^(KBNProject *project) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PROJECT_ADDED object:project];
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
        [weakself.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - HUD

- (void)startHUD {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.HUD.dimBackground = YES;
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    self.HUD.labelText = ADD_PROJECT_LOADING;
    [self.HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    self.HUD.delegate = self;
}

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.040f;
        self.HUD.progress = progress;
        usleep(50000);
    }
    sleep(0.7);
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    self.HUD.customView = imageView;
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = PROJECT_CREATION_SUCCESS;
    sleep(1);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
