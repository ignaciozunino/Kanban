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
#define TASK_SWIPE_THRESHOLD 50
#define RegularTitle @"Delete Tasks"
#define EditingTitle @"Done"

@interface KBNProjectDetailViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;

@property (assign, nonatomic) BOOL cellSelected;


@property CGPoint beginPoint, endPoint;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) KBNTask *selectedTask;
@end

@implementation KBNProjectDetailViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.project.name;
    self.labelState.text = self.taskList.name;
    [self.editButton setTitle:RegularTitle forState:UIControlStateNormal];
    [self.editButton sizeToFit];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    self.tap.delegate = self;
    self.doubleTap.delegate=self;
    self.longPress.delegate = self;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self.tableView isEditing]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

// Tap (Long Press) and Swipe to move a task to the previous/next list
- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _beginPoint = [sender locationInView:self.tableView.superview];
        _selectedIndexPath = [self indexPathForSender:sender];
        _selectedTask = [self.taskListTasks objectAtIndex:_selectedIndexPath.row];
        
        [self toggleSelectedStatus:sender];
        [self.delegate toggleScrollStatus];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        _endPoint = [sender locationInView:self.tableView.superview];
        if (_selectedTask) {
            if (_endPoint.x > _beginPoint.x + TASK_SWIPE_THRESHOLD) {
                // Swipe Right
                [self.delegate moveToRightTask:_selectedTask from:self];
                if (self.pageIndex < self.totalPages -1) {
                    [self removeTask:_selectedTask];
                }
            } else if (_endPoint.x < _beginPoint.x - TASK_SWIPE_THRESHOLD) {
                // Swipe Left
                [self.delegate moveToLeftTask:_selectedTask from:self];
                if (self.pageIndex > 0) {
                    [self removeTask:_selectedTask];
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

#pragma mark - Helper methods

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
    [[KBNTaskService sharedInstance] incrementOrderToTaskIds:tasksToBeUpdated by:[NSNumber numberWithInt:-1] completionBlock:^{
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

#pragma mark - TableView edit

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //for now all the task are editable
    return YES;
    
}

- (IBAction)enterEditMode:(id)sender {
    
    if ([self.tableView isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self.tableView setEditing:NO animated:YES];
        
        [self.editButton setTitle:RegularTitle forState:UIControlStateNormal];
        [self.editButton sizeToFit];
        
    }
    else {
        [self.editButton setTitle:EditingTitle forState:UIControlStateNormal];
        [self.editButton sizeToFit];        // Turn on edit mode
        
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the managedObjectContext from the AppDelegate (for use in CoreData Applications)
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [KBNAppDelegate activateActivityIndicator:YES];
        KBNTask *object = [self.taskListTasks objectAtIndex:indexPath.row];
        [[KBNTaskService sharedInstance] removeTask:object.taskId onSuccess:^{
            // Animate the deletion
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                [self removeTask:object];
                [KBNAppDelegate activateActivityIndicator:NO];
            });
        } failure:^(NSError *error) {
            [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
            [KBNAppDelegate activateActivityIndicator:NO];
        }];
        
        
        // Additional code to configure the Edit Button, if any
        if (self.taskListTasks.count == 0) {
            [self.tableView setEditing:NO animated:YES];
            [self.tableView isEditing ];
            [self.editButton setTitle:RegularTitle forState:UIControlStateNormal];
            [self.editButton sizeToFit];
        }
    }
    
}
@end
