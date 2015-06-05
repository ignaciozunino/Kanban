//
//  KBNTutorialContentViewController.m
//  Kanban
//
//  Created by Maxi Casal on 6/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTutorialContentViewController.h"

@interface KBNTutorialContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleActionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation KBNTutorialContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backgroundImageView.image = [UIImage imageNamed:self.imageName];
    self.titleActionLabel.text = self.actionName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
