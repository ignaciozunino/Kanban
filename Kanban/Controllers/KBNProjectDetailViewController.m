//
//  ProjectDetailViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectDetailViewController.h"
#import "KBNAppDelegate.h"
#import "KBNTaskDetailViewController.h"
#import "KBNTaskService.h"
#import "KBNAlertUtils.h"

#define TABLEVIEW_TASK_CELL @"TaskCell"
#define SEGUE_TASK_DETAIL @"taskDetail"
#define SEGUE_ADD_TASK @"addTask"


@interface KBNProjectDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;

@property (assign, nonatomic) BOOL cellSelected;

@end

@implementation KBNProjectDetailViewController {
    CGPoint beginPoint, endPoint;
    NSIndexPath *selectedIndexPath;
    KBNTask *selectedTask;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.project.name;
    self.labelState.text = self.taskList.name;
    
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskListTasks count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_TASK_CELL forIndexPath:indexPath];
    
    KBNTask* task = [self.taskListTasks objectAtIndex:indexPath.row];
    cell.textLabel.text = task.name;
    
    return cell;
    
}

#pragma mark - Gestures Handlers

// Tap (Long Press) and Swipe to move a task to the previous/next list
- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        beginPoint = [sender locationInView:self.tableView.superview];
        selectedIndexPath = [self indexPathForSender:sender];
        selectedTask = [self.taskListTasks objectAtIndex:selectedIndexPath.row];
        
        [self toggleSelectedStatus:sender];
        [self.delegate toggleScrollStatus];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        endPoint = [sender locationInView:self.tableView.superview];
        if (selectedTask) {
            if (endPoint.x > beginPoint.x + 50) {
                // Swipe Right
                [self.delegate moveToRightTask:selectedTask from:self];
                if (self.pageIndex < self.totalPages -1) {
                    [self removeTask:selectedTask];
                }
            } else if (endPoint.x < beginPoint.x - 50) {
                // Swipe Left
                [self.delegate moveToLeftTask:selectedTask from:self];
                if (self.pageIndex > 0) {
                    [self removeTask:selectedTask];
                }
            }
        }
        
        [self toggleSelectedStatus:sender];
        [self.delegate toggleScrollStatus];
    }
}

// Double Tap to move a task to the next list
- (IBAction)handleDoubleTap:(UITapGestureRecognizer *)sender {
    
    NSIndexPath *indexPath = [self indexPathForSender:sender];
    KBNTask *task = [self.taskListTasks objectAtIndex:indexPath.row];
    [self.delegate moveToRightTask:task from:self];
    [self removeTask:task];

}

// Tap to display task details
- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    
    if (self.cellSelected) {
        [self toggleSelectedStatus:sender];
    } else {
        [self performSegueWithIdentifier:SEGUE_TASK_DETAIL sender:sender];
        [self.tableView deselectRowAtIndexPath:[self indexPathForSender:sender] animated:YES];
    }
}

- (void)toggleSelectedStatus:(UIGestureRecognizer *)sender {
    
    if (self.cellSelected) {
        [self.tableView deselectRowAtIndexPath:[self indexPathForSender:sender] animated:NO];
    } else {
        [self.tableView selectRowAtIndexPath:[self indexPathForSender:sender] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    self.cellSelected = !self.cellSelected;
}

- (NSIndexPath *)indexPathForSender:(UIGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.tableView];
    return [self.tableView indexPathForRowAtPoint:point];
}

// Removes task from the the current list array when it´s moved to another list and reload data
- (void)removeTask:(KBNTask*)task {
    
    // Get the index of the task to be removed
    NSUInteger index = [self.taskListTasks indexOfObject:task];
    
    // Remove the task from the list
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.taskListTasks];
    [temp removeObject:task];
    self.taskListTasks = temp;
    
    [self.tableView reloadData];
    
    // Compress orders in the taskList
    NSMutableArray* tasksToBeUpdated = [[NSMutableArray alloc] init];
    for (int i = (int)index; i < self.taskListTasks.count; i++) {
        [tasksToBeUpdated addObject:[self.taskListTasks[i] taskId]];
    }
    [[KBNTaskService sharedInstance] decrementOrderToTaskIds:tasksToBeUpdated completionBlock:^{
        //
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
    }];
}

#pragma mark - Add Task View Controller delegate

-(void)didCreateTask:(KBNTask *)task {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.taskListTasks];
    [temp addObject:task];
    self.taskListTasks = temp;
    [self.delegate didCreateTask:task];
}

- (NSNumber*)nextOrderNumber {
    return [NSNumber numberWithLong:self.taskListTasks.count];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:SEGUE_TASK_DETAIL]) {
        KBNTaskDetailViewController *taskDetailViewController = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self indexPathForSender:sender];
        taskDetailViewController.task = [self.taskListTasks objectAtIndex:indexPath.row];
        
    } else if ([[segue identifier] isEqualToString:SEGUE_ADD_TASK]) {
        UINavigationController *navController = [segue destinationViewController];
        KBNAddTaskViewController *addTaskViewController = (KBNAddTaskViewController*)navController.topViewController;
        
        addTaskViewController.addTask = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
        
        addTaskViewController.addTask.project = self.project;
        addTaskViewController.addTask.taskList = self.taskList;
        addTaskViewController.delegate = self;
    }
}


@end
