//
//  ProjectDetailViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNProject.h"
#import "Task.h"
#import "KBNConstants.h"


@interface ProjectDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) KBNProject *project;
@property NSUInteger pageIndex;
@property NSArray* tasks;
@property (strong, nonatomic) IBOutlet UILabel *labelState;
@end
