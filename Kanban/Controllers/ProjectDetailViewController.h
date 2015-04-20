//
//  ProjectDetailViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"
#import "Task.h"
#import "Constants.h"


@interface ProjectDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Project *project;
@property NSUInteger pageIndex;
@property NSArray* tasks;
@property (strong, nonatomic) IBOutlet UILabel *labelState;
@end
