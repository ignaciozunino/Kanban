//
//  ProjectPageViewController.h
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTask.h"
#import "KBNTaskList.h"
#import "KBNProject.h"
#import "KBNProjectDetailViewController.h"
#import "KBNAddTaskViewController.h"
#import "KBNConstants.h"
#import "KBNTaskListService.h"

@interface KBNProjectPageViewController : UIViewController<UIPageViewControllerDataSource, KBNProjectDetailViewControllerDelegate, KBNAddTaskViewControllerDelegate>

@property (strong, nonatomic) KBNProject *project;

@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
