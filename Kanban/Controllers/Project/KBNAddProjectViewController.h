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
#import "MBProgressHUD.h"

#define PROJECT_ADDED @"project added"

@interface KBNAddProjectViewController : UIViewController <MBProgressHUDDelegate>

@property (strong, nonatomic) KBNProjectTemplate *selectedTemplate;

@end
