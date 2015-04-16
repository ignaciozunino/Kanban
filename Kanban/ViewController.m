//
//  ViewController.m
//  Kanban
//
//  Created by Nicolas Alejandro Porpiglia on 4/15/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property  NSString * username;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if( ![self isUserLogged]){
        SignInViewController * vc= [[SignInViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        PruebaViewController * vc= [[PruebaViewController alloc]init];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isUserLogged {
    //verifying if we allready signed in before
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.username = [defaults stringForKey:USERDEFAULTS_USERNAME_KEY];
    if (self.username) {
        return YES;
    }
    return NO;
}

@end
