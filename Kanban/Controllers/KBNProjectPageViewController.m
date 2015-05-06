//
//  ProjectPageViewController.m
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectPageViewController.h"
#import "KBNAppDelegate.h"
#import "KBNTaskListUtils.h"
#import "KBNTaskUtils.h"
#import "KBNAlertUtils.h"

#define KBNEDIT_VC @"KBNEditProjectViewController"

@interface KBNProjectPageViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray* projectTasks;
@property (strong, nonatomic) NSArray* projectLists;
@property (strong, nonatomic) NSArray* detailViewControllers; //An array of view controllers built once. Then, every time the user goes to the next/previous page, the corresponding KBNProjectDetailViewController is obtained immediatly from the array, at no cost.

@end

@implementation KBNProjectPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.title = self.project.name;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(setupEdit)];

    [self getProjectListsOnSuccess:^(){
                           // [KBNAlertUtils showAlertView:@"Tasks loaded correctly." andType:@"Alert"];
                         }
                         onFailure:^(NSError* error){
                             [KBNAlertUtils showAlertView:@"Sorry, the tasks could not be retrieved at this moment." andType:@"Alert"];
                         }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data methods

- (void)getProjectLists {
    //This method does the same as "getProjectListsOnSuccess..." but it doesn't require
    //any block to be invoked. Kept this way for backward compatibility.
    [self getProjectListsOnSuccess:^(){} onFailure:^(NSError* error){}];
}


- (void)getProjectListsOnSuccess:(KBNConnectionSuccessBlock)success
                       onFailure:(KBNConnectionErrorBlock)failure {
    __weak typeof(self) weakself = self;
    
    [[KBNTaskListService sharedInstance] getTaskListsForProject:self.project.projectId completionBlock:^(NSDictionary *response) {
        
        NSMutableArray *taskLists = [[NSMutableArray alloc] init];
        
        for (NSDictionary* params in [response objectForKey:@"results"]) {
            [taskLists addObject:[KBNTaskListUtils taskListForProject:self.project params:params]];
        }
        
        weakself.projectLists = taskLists;
        [weakself getProjectTasksOnSuccess:success onFailure:failure];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error getting TaskLists: %@",error.localizedDescription);
        failure(error);
    }];
}

- (void)getProjectTasksOnSuccess:(KBNConnectionSuccessBlock)success
                       onFailure:(KBNConnectionErrorBlock)failure {
    __weak typeof(self) weakself = self;
    
    [[KBNTaskService sharedInstance] getTasksForProject:self.project.projectId completionBlock:^(NSDictionary *response) {
        
        NSMutableArray *tasks = [[NSMutableArray alloc] init];
        
        for (NSDictionary* params in [response objectForKey:@"results"]) {
            if ([[params objectForKey:PARSE_TASK_ACTIVE_COLUMN] boolValue]) {
                NSString* taskListId = [params objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
                KBNTaskList *taskList;
                
                for (KBNTaskList* list in weakself.projectLists) {
                    if ([list.taskListId isEqualToString:taskListId]) {
                        taskList = list;
                        break;
                    }
                }
                [tasks addObject:[KBNTaskUtils taskForProject:weakself.project taskList:taskList params:params]];
            }
        }
        
        weakself.projectTasks = tasks;
        [weakself buildDetailViewControllers];
        [weakself createPageViewController];
        success();
        
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error getting Tasks: %@",error.localizedDescription);
        failure(error);
    }];
}

- (void)getProjectTasks {
    //This method does the same as "getProjectTasksOnSuccess..." but it doesn't require
    //any block to be invoked. Kept this way for backward compatibility.
    [self getProjectTasksOnSuccess:^(){} onFailure:^(NSError* error){}];
}


#pragma mark - Controller methods

-(void)buildDetailViewControllers
{
    NSMutableArray* viewControllers = [[NSMutableArray alloc] init];
    int i = 0;
    for (KBNTaskList* taskList in self.projectLists)
    {
        //Add all detail view controllers to the pageViewController, each one having its own TaskList and array of Lists.
        [viewControllers addObject:[self createViewControllerWithIndex:i
                                                           andTaskList:taskList
                                                              andTasks:[self tasksForList:taskList]]];
        i++;
    }
    self.detailViewControllers = [NSArray arrayWithArray:viewControllers];
}

- (void)createPageViewController {
    
    // Configure appearance for page control indicator
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:PAGE_VC];
    self.pageViewController.dataSource = self;
    
    [self startingViewController];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.scrollView = view;
        }
    }
}

- (void)startingViewController {
    KBNProjectDetailViewController* startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
}

-(KBNProjectDetailViewController*)viewControllerAtIndex:(NSUInteger)index {

    //Check if it is out of bounds
    if (([self.detailViewControllers count] == 0) || (index >= [self.detailViewControllers count]))
    {
        NSLog(@"* * WARNING * * : KBNProjectPageViewController->viewControllerAtIndex: received an index out of bounds. Array count:%lu, Index given:%lu",(unsigned long)[self.detailViewControllers count],(unsigned long)index);
        return nil;
    }
    
    //Just return the view controller at the given index
    return [self.detailViewControllers objectAtIndex:index];

}


-(KBNProjectDetailViewController*)createViewControllerWithIndex:(NSUInteger)index andTaskList:(KBNTaskList*)taskList andTasks:(NSArray*)tasks{
    
    // Create a new view controller and pass suitable data.
    KBNProjectDetailViewController *projectDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:PROJECT_DETAIL_VC];
    
    projectDetailViewController.delegate = self;
    projectDetailViewController.pageIndex = index;
    projectDetailViewController.totalPages = self.projectLists.count;
    projectDetailViewController.project = self.project;
    
    projectDetailViewController.taskListTasks = [NSMutableArray arrayWithArray:tasks];
    projectDetailViewController.taskList = taskList;
    
    return projectDetailViewController;
}


-(NSMutableArray*)tasksForList:(KBNTaskList*)list {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (KBNTask* task in self.projectTasks) {
        if ([task.taskList.taskListId isEqualToString:list.taskListId]){
            [result addObject:task];
        }
    }
    return result;
}

#pragma mark - Page View Controller Data Source

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KBNProjectDetailViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KBNProjectDetailViewController*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [self.projectLists count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.projectLists count];
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return ((KBNProjectDetailViewController*)[self.pageViewController.viewControllers lastObject]).pageIndex;
}

#pragma mark - Project Detail View Controller Delegate

- (void)moveToRightTask:(KBNTask *)task from:(KBNProjectDetailViewController *)viewController {
    
    KBNProjectDetailViewController* viewControllerAtTheRight = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerAfterViewController:viewController];
    
    __block NSMutableArray *senderTasks = viewController.taskListTasks;
    __block NSMutableArray *receiverTasks = viewControllerAtTheRight.taskListTasks;
    
    if (viewControllerAtTheRight) {
        // In case of failure, hold the original values for rollback
        __block NSNumber *holdOrder = task.order;
        __block KBNTaskList *holdTaskList = task.taskList;
        
        // Update task values
        task.order = [NSNumber numberWithUnsignedLong:receiverTasks.count];
        task.taskList = viewControllerAtTheRight.taskList;
        
        // Move it to the next page
        [senderTasks removeObject:task];
        [receiverTasks addObject:task];
        
        // Update task status on server
        [[KBNTaskService sharedInstance] moveTask:task from:senderTasks completionBlock:^{
            // task moved
        } errorBlock:^(NSError *error) {
            task.order = holdOrder;
            task.taskList = holdTaskList;
            
            [senderTasks addObject:task];
            [receiverTasks removeObject:task];

            [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
        }];
        
        [viewController.tableView reloadData];
    }
}

- (void)moveToLeftTask:(KBNTask *)task from:(KBNProjectDetailViewController *)viewController {
    
    KBNProjectDetailViewController* viewControllerAtTheLeft = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerBeforeViewController:viewController];
    
    __block NSMutableArray *senderTasks = viewController.taskListTasks;
    __block NSMutableArray *receiverTasks = viewControllerAtTheLeft.taskListTasks;
    
    if (viewControllerAtTheLeft) {
        // In case of failure, hold the original values for rollback
        __block NSNumber *holdOrder = task.order;
        __block KBNTaskList *holdTaskList = task.taskList;
        
        // Update task values
        task.order = [NSNumber numberWithUnsignedLong:receiverTasks.count];
        task.taskList = viewControllerAtTheLeft.taskList;
        
        // Move it to the next page
        [senderTasks removeObject:task];
        [receiverTasks addObject:task];
        
        // Update task status on server
        [[KBNTaskService sharedInstance] moveTask:task from:senderTasks completionBlock:^{
            // task moved
        } errorBlock:^(NSError *error) {
            task.order = holdOrder;
            task.taskList = holdTaskList;
            
            [senderTasks addObject:task];
            [receiverTasks removeObject:task];
            
            [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
        }];
        
        [viewController.tableView reloadData];
    }
}

- (void)toggleScrollStatus {
    self.scrollView.scrollEnabled = !self.scrollView.scrollEnabled;
}

#pragma mark - Navigation

- (void)setupEdit {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KBNEditProjectViewController *vc = [storyboard instantiateViewControllerWithIdentifier:KBNEDIT_VC];
    vc.project = self.project;
    [self.navigationController pushViewController:vc animated:YES];
}
/*
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 
 }
 */

@end
