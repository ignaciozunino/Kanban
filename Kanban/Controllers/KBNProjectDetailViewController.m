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
#import "KBNTaskListUtils.h"
#import "KBNAlertUtils.h"

#define TABLEVIEW_TASK_CELL @"TaskCell"
#define SEGUE_TASK_DETAIL @"taskDetail"
#define SEGUE_ADD_TASK @"addTask"
#define SEGUE_EDIT_PROJECT @"editProject"
#define TASK_SWIPE_THRESHOLD 50
#define REGULAR_TITLE @"Delete"
#define EDITING_TITLE @"Done"

#define TASK_ROW_HEIGHT 80

@interface KBNProjectDetailViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tap;

@end

@implementation KBNProjectDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.project.name;
    self.labelTaskListName.text = self.taskList.name;
    [self.deleteButton setTitle:REGULAR_TITLE forState:UIControlStateNormal];
    [self.deleteButton sizeToFit];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.tap requireGestureRecognizerToFail:self.doubleTap];
    self.tap.delegate = self;
    self.doubleTap.delegate=self;
    self.longPress.delegate = self;
    
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    
    if (!self.taskListTasks.count) {
        [self.deleteButton setHidden:YES];
        [self.deleteButton setEnabled:NO];
    } else {
        [self.deleteButton setHidden:NO];
        [self.deleteButton setEnabled:YES];
    }

    self.title = self.project.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

#pragma mark - IBActions

- (IBAction)addTaskList:(id)sender {
    
    NSString *currentList = [@" " stringByAppendingString:self.labelTaskListName.text];
    NSString *beforeTitle = [BEFORE_TITLE stringByAppendingString:currentList];
    NSString *afterTitle = [AFTER_TITLE stringByAppendingString:currentList];
    
    NSString *message = nil;
    if ([sender isKindOfClass:[NSError class]]) {
        message = CREATING_TASKLIST_WITHOUT_NAME_ERROR;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ADD_LIST_TITLE
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:CANCEL_TITLE
                                          otherButtonTitles:beforeTitle, afterTitle, nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (!buttonIndex) {
        return;
    }
    
    NSString *taskListName = [[alertView textFieldAtIndex:0] text];
    
    if (taskListName.length) {
        
        KBNTaskList *taskList = [KBNTaskListUtils taskListWithName:taskListName];
        
        switch (buttonIndex) {
            case 1: //Before
                if ([[[alertView textFieldAtIndex:0] text] length]) {
                    [self.delegate insertTaskList:taskList before:self];
                    [self.delegate moveBackwardFrom:self];
                }
                break;
            case 2: //After
                if ([[[alertView textFieldAtIndex:0] text] length]) {
                    [self.delegate insertTaskList:taskList after:self];
                    [self.delegate moveForwardFrom:self];
                }
                break;
        }
    } else {
        [self addTaskList:[NSError new]];
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskListTasks count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_TASK_CELL forIndexPath:indexPath];
    
    KBNTask* task = [self.taskListTasks objectAtIndex:indexPath.row];
    cell.textLabel.text = task.name;
    cell.layer.shadowOffset = CGSizeMake(-1, 1);
    cell.layer.shadowOpacity = 0.5;
    
    return cell;
    
}

#pragma mark - Table View Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //for now all the task are editable
    return YES;
    
}

- (IBAction)enterEditMode:(id)sender {
    
    if ([self.tableView isEditing]) {
        // If the tableView is already in edit mode, turn it off. Also change the title of the button to reflect the intended verb (‘Edit’, in this case).
        [self.tableView setEditing:NO animated:YES];
        
        [self.deleteButton setTitle:REGULAR_TITLE forState:UIControlStateNormal];
        [self.deleteButton sizeToFit];
        
    }
    else {
        [self.deleteButton setTitle:EDITING_TITLE forState:UIControlStateNormal];
        [self.deleteButton sizeToFit];
        
        // Turn on edit mode
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        KBNTask *task = [self.taskListTasks objectAtIndex:indexPath.row];
        
        //First remove it from data source
        [self.taskListTasks removeObjectAtIndex:indexPath.row];
        
        // Then ask the service to remove it from the taskList
        [[KBNTaskService sharedInstance] removeTask:task
                                    completionBlock:^{
                                        // Task removed
                                    } errorBlock:^(NSError *error) {
                                        // Re-insert task at its original position
                                        __weak typeof(self) weakself = self;
                                        [weakself.taskListTasks insertObject:task atIndex:indexPath.row];
                                        [weakself.tableView reloadData];
                                        
                                        [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
                                    }];
        
        [self.tableView reloadData];
        
        // Additional code to configure the Edit Button, if any
        if (self.taskListTasks.count == 0) {
            [self.tableView setEditing:NO animated:YES];
            [self.deleteButton setTitle:REGULAR_TITLE forState:UIControlStateNormal];
            [self.deleteButton sizeToFit];
        }
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TASK_ROW_HEIGHT;
}


#pragma mark - Gestures Handlers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([self.tableView isEditing]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

// Tap (Long Press) and Swipe to move a task to the previous/next list
- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    
    UIGestureRecognizerState state = sender.state;
    
    CGPoint location = [self.longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView *snapshot = nil;               // A snapshot of the row user is moving.
    static NSIndexPath *sourceIndexPath = nil;   // Initial index path, where gesture begins.
    static CGPoint sourceLocation;
    static KBNTask *selectedTask = nil;
    
    if (state == UIGestureRecognizerStateBegan) {
        
        if (indexPath) {
            sourceIndexPath = indexPath;
            sourceLocation = location;
            selectedTask = [self.taskListTasks objectAtIndex:sourceIndexPath.row];
            
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            // Take a snapshot of the selected row using helper method.
            snapshot = [self customSnapshoFromView:cell];
            
            // Add the snapshot as subview, centered at cell's center...
            __block CGPoint center = cell.center;
            snapshot.center = center;
            snapshot.alpha = 0.0;
            [self.tableView addSubview:snapshot];
            [UIView animateWithDuration:0.25 animations:^{
                
                // Offset for gesture location.
                center.y = location.y;
                snapshot.center = center;
                snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                snapshot.alpha = 0.98;
                cell.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                
                cell.hidden = YES;
                
            }];
        }
        
    } else if (state == UIGestureRecognizerStateChanged) {
        CGPoint center = snapshot.center;
        center.y = location.y;
        snapshot.center = center;
        
        // Is destination valid and is it different from source?
        if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
            
            // ... update data source.
            [self.taskListTasks exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
            
            // ... move the rows.
            [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
            
            // ... and update source so it is in sync with UI changes.
            sourceIndexPath = indexPath;
        }
        
    } else if (state == UIGestureRecognizerStateEnded) {
        
        NSIndexPath *originIndexPath = [NSIndexPath indexPathForRow:[selectedTask.order integerValue] inSection:0];
        
        CGPoint endPoint;
        BOOL swipeDetected = NO;
        
        if (sourceIndexPath.row != originIndexPath.row) {
            
            [[KBNTaskService sharedInstance] moveTask:selectedTask
                                               toList:selectedTask.taskList
                                              inOrder:[NSNumber numberWithUnsignedLong:sourceIndexPath.row]
                                      completionBlock:^{
                                          // Tasks reordered within the list
                                      } errorBlock:^(NSError *error) {
                                          __weak typeof(self) weakself = self;
                                          [weakself.taskListTasks removeObject:selectedTask];
                                          [weakself.taskListTasks insertObject:selectedTask atIndex:originIndexPath.row];
                                          
                                          [weakself.tableView reloadData];
                                          
                                          [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
                                      }];
            
        } else {
            
            if (location.x > sourceLocation.x + TASK_SWIPE_THRESHOLD) {
                // Swipe Right
                [self.delegate moveToRightTask:selectedTask from:self];
                
                // Prepare for animation
                if (self.pageIndex < self.totalPages -1) {
                    endPoint = CGPointMake(9999, location.y);
                    swipeDetected = YES;
                }
            } else if (location.x < sourceLocation.x - TASK_SWIPE_THRESHOLD) {
                // Swipe Left
                [self.delegate moveToLeftTask:selectedTask from:self];
                
                // Prepare for animation
                if (self.pageIndex > 0) {
                    endPoint = CGPointMake(-9999, location.y);
                    swipeDetected = YES;
                }
            }
        }
        
        // Clean up.
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
        cell.hidden = NO;
        cell.alpha = 0.0;
        
        NSTimeInterval duration;
        
        if (swipeDetected) {
            duration = 2.5;
        } else {
            duration = 0.25;
        }
        
        [UIView animateWithDuration:duration animations:^{
            
            snapshot.center = CGPointMake(cell.center.x + endPoint.x, cell.center.y);
            snapshot.transform = CGAffineTransformIdentity;
            snapshot.alpha = 0.0;
            cell.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            sourceIndexPath = nil;
            [snapshot removeFromSuperview];
            snapshot = nil;
            
        }];
    }
}

// Double Tap to move a task to the next list
- (IBAction)handleDoubleTap:(UITapGestureRecognizer *)sender {
    
    if (self.pageIndex < self.totalPages -1) {
        
        CGPoint location = [self.doubleTap locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        //Prepare for animation
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        // Take a snapshot of the selected row using helper method.
        UIView *snapshot = [self customSnapshoFromView:cell];
        
        // Add the snapshot as subview, centered at cell's center...
        __block CGPoint center = cell.center;
        snapshot.center = center;
        [self.tableView addSubview:snapshot];
        
        // Move the task to the next list
        KBNTask *task = [self.taskListTasks objectAtIndex:indexPath.row];
        [self.delegate moveToRightTask:task from:self];
        
        // Animate the movement
        [UIView animateWithDuration:2.5 animations:^{
            snapshot.center = CGPointMake(9999, cell.center.y);
        } completion:^(BOOL finished) {
            [snapshot removeFromSuperview];
        }];
    }
}

// Tap to display task details
- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    
    [self performSegueWithIdentifier:SEGUE_TASK_DETAIL sender:sender];
    [self.tableView deselectRowAtIndexPath:[self indexPathForSender:sender] animated:YES];
    
}

#pragma mark - Helper methods

// Returns a customized snapshot of a given view
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (NSIndexPath *)indexPathForSender:(UIGestureRecognizer *)sender {
    
    CGPoint point = [sender locationInView:self.tableView];
    return [self.tableView indexPathForRowAtPoint:point];
}

#pragma mark - Add Task View Controller delegate

-(void)didCreateTask:(KBNTask *)task {
    [self.taskListTasks addObject:task];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:SEGUE_TASK_DETAIL]) {
        KBNTaskDetailViewController *taskDetailViewController = [segue destinationViewController];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSIndexPath *indexPath = [self indexPathForSender:sender];
        taskDetailViewController.task = [self.taskListTasks objectAtIndex:indexPath.row];
        
    } else if ([[segue identifier] isEqualToString:SEGUE_ADD_TASK]) {
        //Make sure the list will accept another item before trying to add the task
        if ([[KBNTaskListService sharedInstance] hasCountLimitBeenReached:self.taskList]){
            [KBNAlertUtils showAlertView:CREATING_TASK_TASKLIST_FULL andType:ERROR_ALERT];
        } else {
            [self goToAddTaskScreen:[segue destinationViewController]];
        }
    }
}

-(void)goToAddTaskScreen:(UINavigationController*)navController{
    KBNAddTaskViewController *addTaskViewController = (KBNAddTaskViewController*)navController.topViewController;
    
    addTaskViewController.addTask = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TASK inManagedObjectContext:[self managedObjectContext]];
    
    addTaskViewController.addTask.project = self.project;
    addTaskViewController.addTask.taskList = self.taskList;
    addTaskViewController.delegate = self;
}

@end
