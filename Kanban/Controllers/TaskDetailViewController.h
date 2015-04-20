//
//  TaskDetailViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskDetailViewController : UIViewController

@property (strong, nonatomic) Task *task;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;

@end
