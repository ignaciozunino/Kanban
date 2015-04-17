//
//  SignInViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//
#import "SignInViewController.h"

@interface SignInViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@end

@implementation SignInViewController

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
    if ([self isValidUsername:username] && [self isValidPassword:password]) {
        
        [UserUtils saveUsernameInUserDefaults:username];
        
        KBNUser *user = [KBNUser new];
        user.username = username;
        user.password = password;
        [[KBNDataService sharedInstance] createUser:user completionBlock:^{
            PruebaViewController * vc= [[PruebaViewController alloc]init];
            [self presentViewController:vc animated:YES completion:nil];
            
        } errorBlock:^(NSError *error) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"CONNECTION ERROR!"
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }];
    }else{
        [self showAlertView:@"Please verify the username is a valid email and the password has at least 6 characters, one letter and one number."];
    }
}

//This method is to dismiss keyboard
- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - Validators methods

//This method is to verify that the email has valid format
-(BOOL) isValidUsername:(NSString*) username{
    return [UserUtils isValidUsername:username];
}

//This method is to verify that the password has valid format
-(BOOL) isValidPassword:(NSString*) password{
    return [UserUtils isValidPassword:password];
}

-(void) showAlertView:(NSString*) message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - initializer methods
//This method is to add placeholders to username and password text fields
-(void) setupPlaceholders {
    UIColor *color = [UIColor whiteColor];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
}

@end
