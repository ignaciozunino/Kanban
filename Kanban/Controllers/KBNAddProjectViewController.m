//
//  AddProjectViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNAddProjectViewController.h"

@interface KBNAddProjectViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@end

@implementation KBNAddProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)save:(UIBarButtonItem *)sender {
    
        [[KBNProjectService sharedInstance]createProject:self.nameTextField.text withDescription:self.descriptionTextField.text completionBlock:^{
            [KBNAlertUtils showAlertView:PROJECT_CREATION_SUCCES andType:SUCCES_ALERT];
            [self dismissViewControllerAnimated:YES completion:nil];
        } errorBlock:^(NSError *error) {
            [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
        }];
    
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
