//
//  AddTaskViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTask.h"

@protocol KBNAddTaskViewControllerDelegate <NSObject>

- (void)didCreateTask:(KBNTask*)task;

- (NSNumber*)nextOrderNumber;

@end


@interface KBNAddTaskViewController : UIViewController

@property (strong, nonatomic) KBNTask *addTask;

@property (strong, nonatomic) NSArray* taskListTasks;

@property (weak, nonatomic) id <KBNAddTaskViewControllerDelegate> delegate;


@end
