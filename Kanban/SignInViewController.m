//
//  SignInViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//
#import "Constants.h"
#import "SignInViewController.h"
#import "PruebaViewController.h"
#import "KBNUser.h"
#import "KBNProxy.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPlaceholders];
}
- (IBAction)onSignInPressed:(UIButton *)sender {
    if ([self isValidUsername] && [self isValidPassword]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.usernameTextField.text forKey:USERDEFAULTS_USERNAME_KEY];
        [defaults synchronize];
        PruebaViewController * vc= [[PruebaViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
        KBNUser *user = [KBNUser new];
        user.username = self.usernameTextField.text;
        user.password = self.passwordTextField.text;
        [[KBNProxy sharedInstance] createUser:user];
    }else{
        NSLog(@"Wrong data");
    }
}

-(BOOL) isValidUsername{
    return YES;
}

-(BOOL) isValidPassword{
    return YES;
}

//This method is to add placeholders to username and password text fields
-(void) setupPlaceholders {
    UIColor *color = [UIColor whiteColor];
    self.usernameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    
}

@end
