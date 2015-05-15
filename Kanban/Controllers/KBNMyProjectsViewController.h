//
//  MyProjectsViewController.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNAddProjectViewController.h"

@interface KBNMyProjectsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, KBNAddProjectViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
