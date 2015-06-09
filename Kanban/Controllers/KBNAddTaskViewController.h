//
//  AddTaskViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTask.h"
#import "MBProgressHUD.h"

@protocol KBNAddTaskViewControllerDelegate <NSObject>

- (void)didCreateTask:(KBNTask*)task;

@end

@interface KBNAddTaskViewController : UIViewController <UITextFieldDelegate, MBProgressHUDDelegate>

@property (strong, nonatomic) KBNTask *addTask;
@property (weak, nonatomic) id <KBNAddTaskViewControllerDelegate> delegate;

@end
