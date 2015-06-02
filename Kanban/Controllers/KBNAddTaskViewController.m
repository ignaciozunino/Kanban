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

@interface KBNAddTaskViewController () <MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property MBProgressHUD* HUD;

@end

@implementation KBNAddTaskViewController

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
    [self.view endEditing:YES];
    [self startHUD];
    self.addTask.name = self.nameTextField.text;
    self.addTask.taskDescription = self.descriptionTextView.text;
    
    __weak typeof(self) weakself = self;
    
    [[KBNTaskService sharedInstance] createTask:self.addTask inList:self.addTask.taskList completionBlock:^(NSDictionary *response) {
        weakself.addTask.taskId = [response objectForKey:PARSE_OBJECTID];
        [weakself.delegate didCreateTask:weakself.addTask];
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
        [weakself dismissViewControllerAnimated:YES completion:nil];
        
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
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
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    sleep(0.5);
    self.HUD.customView = imageView;
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = TASK_CREATION_SUCCESS;
    sleep(1);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
