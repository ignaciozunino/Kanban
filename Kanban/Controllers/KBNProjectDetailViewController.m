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

@end

@implementation KBNProjectDetailViewController

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
    cell.detailTextLabel.text = task.taskDescription;
    
    // Assign a background image for the cell
    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
    
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    cell.backgroundView = cellBackgroundView;
    
    return cell;
    
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    
    return background;
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
    
    UIGestureRecognizerState state = sender.state;
    
    CGPoint location = [self.longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView *snapshot = nil;               // A snapshot of the row user is moving.
    static NSIndexPath *sourceIndexPath = nil;   // Initial index path, where gesture begins.
    static NSIndexPath *holdIndexPath = nil;    // Hold index path of the previous gesture to detect change of cells.
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
            holdIndexPath = sourceIndexPath;
            sourceIndexPath = indexPath;
        }
        
    } else if (state == UIGestureRecognizerStateEnded) {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
        NSUInteger origin = [selectedTask.order integerValue];
        
        if (holdIndexPath && sourceIndexPath.row != holdIndexPath.row && sourceIndexPath.row != origin) {
            [self updateOrdersForExchangeFrom:origin to:sourceIndexPath.row];
        } else {
            if (location.x > sourceLocation.x + TASK_SWIPE_THRESHOLD) {
                // Swipe Right
                [self.delegate moveToRightTask:selectedTask from:self];
                if (self.pageIndex < self.totalPages -1) {
                    [self removeTask:selectedTask];
                }
            } else if (location.x < sourceLocation.x - TASK_SWIPE_THRESHOLD) {
                // Swipe Left
                [self.delegate moveToLeftTask:selectedTask from:self];
                if (self.pageIndex > 0) {
                    [self removeTask:selectedTask];
                }
            }
        }
        
        // Clean up.
        cell.hidden = NO;
        cell.alpha = 0.0;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            snapshot.center = CGPointMake(cell.center.x, cell.center.y);
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
    
    NSIndexPath *indexPath = [self indexPathForSender:sender];
    KBNTask *task = [self.taskListTasks objectAtIndex:indexPath.row];
    [self.delegate moveToRightTask:task from:self];
    [self removeTask:task];
    
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

// Receives a task from the outside, and adds it to the local list of tasks.
-(void) receiveTask:(KBNTask *)task {
    
    [self.taskListTasks addObject:task];
    
}

// Removes task from the the current list array when it´s moved to another list and reload data
- (void)removeTask:(KBNTask*)task {
    
    // Get the index in the array before removing
    NSUInteger index = [self.taskListTasks indexOfObject:task];
    
    // Remove the task from the list
    [self.taskListTasks removeObject:task];
    [self.tableView reloadData];
    
    // Compress orders in the taskList at server.
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

// Reorder task in the the current list array when it´s moved to another place in the same list
- (void)updateOrdersForExchangeFrom:(NSUInteger)start to:(NSUInteger)end {
    
    // Update task order and re-arrange orders in the taskList at server.
    
    KBNTask *task = self.taskListTasks[end];
    [task setOrder:[NSNumber numberWithUnsignedInteger:end]];
    
    
    // First determine other tasks to be updated
    NSMutableArray* tasksToBeUpdated = [[NSMutableArray alloc] init];
    NSNumber *amount;
    NSUInteger index;
    
    if (start < end) {
        for (index = start; index < end; index++) {
            [self.taskListTasks[index] setOrder:[NSNumber numberWithUnsignedInteger:index]];
            [tasksToBeUpdated addObject:[self.taskListTasks[index] taskId]];
        }
        amount = @-1;
    } else {
        for (index = start; index > end; index--) {
            [self.taskListTasks[index] setOrder:[NSNumber numberWithUnsignedInteger:index]];
            [tasksToBeUpdated addObject:[self.taskListTasks[index] taskId]];
        }
        amount = @1;
    }
    
    // Update tasks orden on persistance system
    KBNTaskService *taskService = [KBNTaskService sharedInstance];
    
    [taskService updateTask:task.taskId order:[NSNumber numberWithUnsignedInteger:end] completionBlock:^{
        [taskService incrementOrderToTaskIds:tasksToBeUpdated by:amount completionBlock:^{
            // Tasks updated
        } errorBlock:^(NSError *error) {
            [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
        }];
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
    }];
}

#pragma mark - Add Task View Controller delegate

-(void)didCreateTask:(KBNTask *)task {
    
    [self.taskListTasks addObject:task];
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
        [self.editButton sizeToFit];
        
        // Turn on edit mode
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
            [self.editButton setTitle:RegularTitle forState:UIControlStateNormal];
            [self.editButton sizeToFit];
        }
    }
    
}
@end
