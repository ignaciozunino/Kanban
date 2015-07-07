//
//  ProjectPageViewController.m
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectPageViewController.h"
#import "KBNEditProjectViewController.h"
#import "KBNAppDelegate.h"
#import "KBNTaskListUtils.h"
#import "KBNTaskUtils.h"
#import "KBNAlertUtils.h"
#import "KBNUpdateManager.h"
#import "KBNUpdateUtils.h"
#import "KBNReachabilityUtils.h"
#import "KBNReachabilityWidgetView.h"

#define KBNEDIT_VC @"KBNEditProjectViewController"
#define KBNEDIT_PROJECT_NAV_CONTROLLER @"KBNEditProjectNavigationController"

@interface KBNProjectPageViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray* projectTasks;
@property (strong, nonatomic) NSMutableArray* projectLists;
@property (strong, nonatomic) NSMutableArray* detailViewControllers; //An array of view controllers built once. Then, every time the user goes to the next/previous page, the corresponding KBNProjectDetailViewController is obtained immediatly from the array, at no cost.

@property (weak, nonatomic) IBOutlet KBNReachabilityWidgetView *reachabilityView;

@end

@implementation KBNProjectPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.project.name;
    
    self.projectTasks = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                          target:self
                                                                                          action:@selector(setupEdit)];
    [self getProjectLists];
    
    [self subscribeToNotifications];
}

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectUpdate:) name:UPDATE_PROJECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTaskListUpdate:) name:UPDATE_TASKLIST object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Handlers

- (void)onProjectUpdate:(NSNotification *)notification{
    // This view controller displays the project name in the title. On project change, change the title accordingly.
    KBNProject *updatedProject = (KBNProject*)notification.object;
    if ([self.project.projectId isEqualToString:updatedProject.projectId]) {
        self.project = updatedProject;
        self.title = self.project.name;
    }
}

- (void)onTaskListUpdate:(NSNotification*)notification {
    KBNTaskList *taskList = (KBNTaskList*)notification.object;
    [self insertTaskList:taskList atIndex:taskList.order.integerValue notified:YES];
}

#pragma mark - Private methods

- (void)getProjectLists {
    __weak typeof(self) weakself = self;
    [[KBNTaskListService sharedInstance] getTaskListsForProject:self.project completionBlock:^(NSArray *records) {
        weakself.projectLists = [NSMutableArray arrayWithArray:records];
        [weakself getProjectTasks];
    } errorBlock:^(NSError *error) {
    }];
}

- (void)getProjectTasks {
    __weak typeof(self) weakself = self;
    [[KBNTaskService sharedInstance] getTasksForProject:self.project completionBlock:^(NSArray *records) {
        weakself.projectTasks = [NSMutableArray arrayWithArray:records];
        [weakself buildDetailViewControllers];
        [weakself createPageViewController];

    } errorBlock:^(NSError *error) {
    }];
}

#pragma mark - Controller methods

-(void)buildDetailViewControllers {
    
    self.detailViewControllers = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (KBNTaskList* taskList in self.projectLists) {
        
        //Add all detail view controllers to the pageViewController, each one having its own TaskList and array of Lists.
        [self.detailViewControllers addObject:[self createViewControllerWithIndex:i
                                                                      andTaskList:taskList
                                                                         andTasks:[self tasksForList:taskList]]];
        i++;
    }
}

- (void)createPageViewController {
    
    // Configure appearance for page control indicator
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = UIColorFromRGB(LIGHT_GRAY);
    
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
    projectDetailViewController.enable = YES;
    
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
    
    KBNProjectDetailViewController* destinationViewController = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerAfterViewController:viewController];
    
    [self moveTask:task from:viewController to:destinationViewController];
    
}

- (void)moveToLeftTask:(KBNTask *)task from:(KBNProjectDetailViewController *)viewController {
    
    KBNProjectDetailViewController* destinationViewController = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerBeforeViewController:viewController];
    
    [self moveTask:task from:viewController to:destinationViewController];
    
}

- (void)moveTask:(KBNTask *)task from:(KBNProjectDetailViewController *)viewController to:(KBNProjectDetailViewController *)destinationViewController {
    
    __block NSMutableArray *senderTasks = viewController.taskListTasks;
    __block NSMutableArray *receiverTasks = destinationViewController.taskListTasks;
    
    if (destinationViewController) {
        // In case of failure, hold the original values for rollback
        NSUInteger holdIndex = [senderTasks indexOfObject:task];
        
        // Move the task to the next page tasks array
        [senderTasks removeObject:task];
        [receiverTasks addObject:task];
        
        // Ask the service to move the task
        [[KBNTaskService sharedInstance] moveTask:task
                                           toList:destinationViewController.taskList
                                          inOrder:nil
                                  completionBlock:^{
                                      // task moved
                                  } errorBlock:^(NSError *error) {
                                      [senderTasks insertObject:task atIndex:holdIndex];
                                      [receiverTasks removeObject:task];
                                      [viewController.tableView reloadData];
                                      [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
                                  }];
        
        [viewController.tableView reloadData];
    }
}

- (void)insertTaskList:(KBNTaskList*)taskList before:(KBNProjectDetailViewController *)viewController {
    [self insertTaskList:(KBNTaskList*)taskList atIndex:viewController.pageIndex notified:NO];
}

- (void)insertTaskList:(KBNTaskList*)taskList after:(KBNProjectDetailViewController *)viewController {
    [self insertTaskList:(KBNTaskList*)taskList atIndex:viewController.pageIndex + 1 notified:NO];
}

- (void)insertTaskList:(KBNTaskList*)taskList atIndex:(NSUInteger)index notified:(BOOL)notified {
    
    // This view controller handles two arrays:
    // 1. projectLists
    // 2. detailViewControllers
    // We have to insert new objects (task list and detail view controller) in the corresponding array.
    
    [self.projectLists insertObject:taskList atIndex:index];
    
    KBNProjectDetailViewController *newProjectDetailViewController = [self createViewControllerWithIndex:index andTaskList:taskList andTasks:nil];
    
    [newProjectDetailViewController setEnable:NO];
    
    [self.detailViewControllers insertObject:newProjectDetailViewController atIndex:index];
    
    [self updateViewControllersArray];
    
    if (!notified) {
        __weak typeof(self) weakself = self;
        [[KBNTaskListService sharedInstance] createTaskList:taskList forProject:self.project inOrder:[NSNumber numberWithUnsignedLong:index] completionBlock:^(KBNTaskList *taskList) {
            // Enable edition on new task list
            [newProjectDetailViewController setEnable:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:ENABLE_VIEW object:nil];
            
        } errorBlock:^(NSError *error) {
            [weakself.projectLists removeObject:taskList];
            [weakself.detailViewControllers removeObject:newProjectDetailViewController];
            [weakself updateViewControllersArray];
            [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
        }];
    } else {
        [newProjectDetailViewController setEnable:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:ENABLE_VIEW object:nil];
        [self updatePageController];
    }
    
}

- (void)updateViewControllersArray {
    
    NSUInteger i = 0;
    for (KBNProjectDetailViewController *vc in self.detailViewControllers) {
        vc.pageIndex = i;
        vc.totalPages = self.detailViewControllers.count;
        i++;
    }
}

- (void)moveBackwardFrom:(KBNProjectDetailViewController *)viewController {
    
    KBNProjectDetailViewController* destinationViewController = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerBeforeViewController:viewController];
    
    [self.pageViewController setViewControllers:@[destinationViewController]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
}

- (void)moveForwardFrom:(KBNProjectDetailViewController *)viewController {
    
    KBNProjectDetailViewController* destinationViewController = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerAfterViewController:viewController];
    
    [self.pageViewController setViewControllers:@[destinationViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
}

- (void)updatePageController {
    [self.pageViewController setViewControllers:[self.pageViewController viewControllers] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)toggleScrollStatus {
    self.scrollView.scrollEnabled = !self.scrollView.scrollEnabled;
}

#pragma mark - Navigation

- (void)setupEdit {
    
    if ([KBNReachabilityUtils isOffline]) {
        [[[self.pageViewController.viewControllers firstObject] reachabilityView] showAnimated:YES];
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KBNEditProjectViewController *editProjectViewController = [storyboard instantiateViewControllerWithIdentifier:KBNEDIT_VC];
    editProjectViewController.project = self.project;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editProjectViewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

@end

