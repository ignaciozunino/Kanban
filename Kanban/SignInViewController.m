//
//  SignInViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//
#import "SignInViewController.h"

@interface SignInViewController ()

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
    if ([self isValidUsername] && [self isValidPassword]) {
      
        [UserUtils saveUsernameInUserDefaults:self.usernameTextField.text];
        
        //bloque de succes
        PruebaViewController * vc= [[PruebaViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
        //end of succes bloq
        
        KBNUser *user = [KBNUser new];
        user.username = self.usernameTextField.text;
        user.password = self.passwordTextField.text;
        [[KBNDataService sharedInstance] createUser:user]; //llamada con user y 2 bloques
    }else{
        NSLog(@"Wrong data");
    }
}

//This method is to dismiss keyboard
- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - Validators methods

//This method is to verify that the email has valid format
-(BOOL) isValidUsername{
    return YES;
}

//This method is to verify that the password has valid format
-(BOOL) isValidPassword{
    return YES;
}

#pragma mark - initializer methods
//This method is to add placeholders to username and password text fields
-(void) setupPlaceholders {
    UIColor *color = [UIColor whiteColor];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
}

@end
