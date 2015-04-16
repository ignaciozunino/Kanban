//
//  PruebaViewController.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//
#import "Constants.h"
#import "PruebaViewController.h"

@interface PruebaViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation PruebaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.usernameLabel.text = [defaults stringForKey:USERDEFAULTS_USERNAME_KEY];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
