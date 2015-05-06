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

- (void)moveToRightTask:(KBNTask*)task from:(KBNProjectDetailViewController*)viewController;

- (void)moveToLeftTask:(KBNTask*)task from:(KBNProjectDetailViewController*)viewController;

- (void)toggleScrollStatus;

@end

@interface KBNProjectDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KBNAddTaskViewControllerDelegate>

@property (strong, nonatomic) KBNProject *project;

@property (assign, nonatomic) NSUInteger pageIndex;
@property (assign, nonatomic) NSUInteger totalPages;

@property (strong, nonatomic) NSMutableArray* taskListTasks;
@property (strong, nonatomic) KBNTaskList *taskList;

@property (strong, nonatomic) IBOutlet UILabel *labelState;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) id <KBNProjectDetailViewControllerDelegate> delegate;


- (void)removeTask:(KBNTask*)task;

- (void)receiveTask:(KBNTask*)task;

- (void)sendTask:(KBNTask*)task;
@end
