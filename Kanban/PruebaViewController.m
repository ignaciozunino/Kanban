//
//  PruebaViewController.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//
#import "PruebaViewController.h"

/*
 TODO
 Remove this ViewController
 */

@interface PruebaViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation PruebaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.usernameLabel.text = [defaults stringForKey:USERNAME_KEY];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
