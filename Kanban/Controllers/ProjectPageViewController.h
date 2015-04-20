//
//  ProjectPageViewController.h
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "KBNProject.h"
#import "ProjectDetailViewController.h"
#import "KBNConstants.h"

@interface ProjectPageViewController : UIViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) KBNProject *project;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray* tasks;
@property (strong, nonatomic) NSArray* states;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
