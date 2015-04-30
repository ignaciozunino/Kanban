//
//  ProjectDetailViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNTaskList.h"
#import "KBNConstants.h"
#import "KBNAddTaskViewController.h"

@class KBNProjectDetailViewController;

@protocol KBNProjectDetailViewControllerDelegate <NSObject>

- (void)moveToRightFrom:(KBNProjectDetailViewController*)viewController;

- (void)moveToLeftFrom:(KBNProjectDetailViewController*)viewController;

- (void)moveToRightTask:(KBNTask*)task from:(KBNProjectDetailViewController*)viewController;

- (void)moveToLeftTask:(KBNTask*)task from:(KBNProjectDetailViewController*)viewController;

- (void)didCreateTask:(KBNTask*)task;

- (void)toggleScrollStatus;

@end

@interface KBNProjectDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KBNAddTaskViewControllerDelegate>

- (void)removeTask:(KBNTask*)task;

- (void)receiveTask:(KBNTask*)task;

@property (strong, nonatomic) KBNProject *project;

@property NSUInteger pageIndex;
@property NSUInteger totalPages;

@property NSArray* taskListTasks;
@property KBNTaskList *taskList;

@property (strong, nonatomic) IBOutlet UILabel *labelState;

@property (weak, nonatomic) id <KBNProjectDetailViewControllerDelegate> delegate;

@end
