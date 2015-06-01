//
//  SignInViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//
#import "KBNSignInViewController.h"

@interface KBNSignInViewController () <UIAlertViewDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property MBProgressHUD* HUD;
@end

@implementation KBNSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPlaceholders];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (void)startHUD {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.HUD.dimBackground = YES;
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    self.HUD.labelText = @"Connecting";
    [self.HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    self.HUD.delegate = self;
}

- (IBAction)onSignInPressed:(UIButton *)sender {
    [self startHUD];
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    [[KBNUserService sharedInstance] createUser:username withPasword:password  completionBlock:^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
            UIViewController *vc = [storyboard instantiateInitialViewController];            [self presentViewController:vc animated:YES completion:nil];
            [KBNUserUtils saveUsername:username];
        } errorBlock:^(NSError *error) {
            [KBNAlertUtils showAlertView:[KBNErrorUtils getErrorMessage:[error code]] andType:ERROR_ALERT ];
                    }];

}

//This method is to dismiss keyboard
- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


#pragma mark - initializer methods
//This method is to add placeholders to username and password text fields
-(void) setupPlaceholders {
    UIColor *color = [UIColor whiteColor];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
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
