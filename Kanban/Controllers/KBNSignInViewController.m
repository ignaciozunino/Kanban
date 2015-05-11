//
//  SignInViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//
#import "KBNSignInViewController.h"

@interface KBNSignInViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

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
- (IBAction)onSignInPressed:(UIButton *)sender {
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

@end
