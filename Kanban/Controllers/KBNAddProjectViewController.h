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

@interface KBNAddProjectViewController : UIViewController

- (instancetype)initWithService:(KBNProjectService *) projectService;
@property  (nonatomic, strong) KBNProjectService* projectService;

@end
