//
//  EditProjectViewController.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTaskList.h"
#import "KBNProject.h"
#import "KBNProjectService.h"
#import "KBNAlertUtils.h"
#import "KBNAppDelegate.h"
#import "UIFont+CustomFonts.h"

@interface KBNEditProjectViewController : UIViewController

@property KBNProject* project;

@end
