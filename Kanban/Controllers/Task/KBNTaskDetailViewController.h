//
//  TaskDetailViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNAppDelegate.h"
#import "KBNTaskService.h"
#import "KBNAlertUtils.h"

@interface KBNTaskDetailViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) KBNTask *task;

@end
