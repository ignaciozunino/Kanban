//
//  ProjectPageViewController.h
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTask.h"
#import "KBNProject.h"
#import "KBNProjectDetailViewController.h"
#import "KBNConstants.h"

@interface KBNProjectPageViewController : UIViewController<UIPageViewControllerDataSource>

@property (strong, nonatomic) KBNProject *project;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray* tasks;
@property (strong, nonatomic) NSArray* states;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
