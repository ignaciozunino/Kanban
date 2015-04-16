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

//This method is to add placeholders to username and password text fields
-(void) setupPlaceholders {
    UIColor *color = [UIColor grayColor];
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
