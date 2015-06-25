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
#import "KBNTaskListService.h"

#define ENABLE_VIEW @"enable view"

@class KBNProjectDetailViewController;

@protocol KBNProjectDetailViewControllerDelegate <NSObject>

- (void)moveToRightTask:(KBNTask*)task from:(KBNProjectDetailViewController*)viewController;

- (void)moveToLeftTask:(KBNTask*)task from:(KBNProjectDetailViewController*)viewController;

- (void)insertTaskList:(KBNTaskList*)taskList before:(KBNProjectDetailViewController*)viewController notified:(BOOL)notified;

- (void)insertTaskList:(KBNTaskList*)taskList after:(KBNProjectDetailViewController*)viewController notified:(BOOL)notified;

- (void)insertTaskList:(KBNTaskList*)taskList atIndex:(NSUInteger)index notified:(BOOL)notified;

- (void)moveBackwardFrom:(KBNProjectDetailViewController*)viewController;

- (void)moveForwardFrom:(KBNProjectDetailViewController*)viewController;

- (void)toggleScrollStatus;

@end

@interface KBNProjectDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KBNAddTaskViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) KBNProject *project;

@property (assign, nonatomic) NSUInteger pageIndex;
@property (assign, nonatomic) NSUInteger totalPages;
@property (assign, nonatomic) BOOL enable;

@property (strong, nonatomic) NSMutableArray* taskListTasks;
@property (strong, nonatomic) KBNTaskList *taskList;

@property (strong, nonatomic) IBOutlet UILabel *labelTaskListName;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) id <KBNProjectDetailViewControllerDelegate> delegate;

@end
