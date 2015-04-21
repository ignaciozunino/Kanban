//
//  TaskDetailViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNTask.h"

@interface KBNTaskDetailViewController : UIViewController

@property (strong, nonatomic) KBNTask *task;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;

@end
