//
//  AddProjectViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNProjectService.h"
#import "KBNAlertUtils.h"
#import "KBNAppDelegate.h"
#import "KBNUserUtils.h"

@protocol KBNAddProjectViewControllerDelegate <NSObject>

- (void)didCreateProject:(KBNProject*) project;

@end

@interface KBNAddProjectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithService:(KBNProjectService *) projectService;

@property  (nonatomic, strong) KBNProjectService* projectService;

@property (weak, nonatomic) id <KBNAddProjectViewControllerDelegate> delegate;

@end
