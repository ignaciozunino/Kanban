//
//  ProjectPageViewController.m
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectPageViewController.h"
#import "KBNAppDelegate.h"
#import "KBNTaskServiceOld.h"
#import "KBNAlertUtils.h"

@interface KBNProjectPageViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray* projectTasks;
@property (strong, nonatomic) NSArray* projectLists;

@end

@implementation KBNProjectPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.title = self.project.name;
    
    // Configure appearance for page control indicator
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    [self getProjectLists];
    
    [self getProjectTasks];
    
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)startingViewController {
    KBNProjectDetailViewController* startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

#pragma mark - Private methods

- (void)getProjectLists {
    
    // Now projects lists are loaded to all projects in MyProjectsViewController.
    // They should be loaded here for each project, maybe from KBNProjectService (TBD)
    
    self.projectLists = self.project.taskLists.array;
    
}

- (void)getProjectTasks {
    
    [[KBNTaskServiceOld sharedInstance] getTasksForProject:self.project success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak typeof(self) weakself = self;
        NSMutableArray *tasksArray = [[NSMutableArray alloc] init];
        
        NSDictionary *tasks = [responseObject objectForKey:@"results"];
        
        for (NSDictionary* item in tasks) {
            KBNTask *newTask = [[KBNTask alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_TASK
                                                                                    inManagedObjectContext:weakself.managedObjectContext]
                                         insertIntoManagedObjectContext:weakself.managedObjectContext];
            
            newTask.taskId = [item objectForKey:PARSE_OBJECTID];
            newTask.name = [item objectForKey:PARSE_TASK_NAME_COLUMN];
            newTask.taskDescription = [item objectForKey:PARSE_TASK_DESCRIPTION_COLUMN];
            newTask.project = weakself.project;
            
            NSString* taskListId = [item objectForKey:PARSE_TASK_TASK_LIST_COLUMN];
            
            for (KBNTaskList *taskList in newTask.project.taskLists) {
                if ([taskListId isEqualToString:taskList.taskListId]) {
                    newTask.taskList = taskList;
                    [tasksArray addObject:newTask];
                    break;
                }
            }
        }
        
        weakself.projectTasks = tasksArray;
        [weakself startingViewController];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
    }];
}

-(KBNProjectDetailViewController*)viewControllerAtIndex:(NSUInteger)index {
    if (([self.projectLists count] == 0) || (index >= [self.projectLists count]))
    {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    KBNProjectDetailViewController *projectDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:PROJECT_DETAIL_VC];
    
    projectDetailViewController.delegate = self;
    projectDetailViewController.pageIndex = index;
    projectDetailViewController.totalPages = self.projectLists.count;
    projectDetailViewController.project = self.project;
    
    KBNTaskList *currentList = [self.project.taskLists objectAtIndex:index];
    
    projectDetailViewController.taskListTasks = [self tasksForList:currentList];
    projectDetailViewController.taskList = currentList;
    
    return projectDetailViewController;
}

-(NSArray*)tasksForList:(KBNTaskList*)list {
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

- (void)moveToRightFrom:(KBNProjectDetailViewController *)viewController {
    
    if (viewController.pageIndex == [self.projectLists count] - 1) return;
    
    KBNProjectDetailViewController *nextViewController = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerAfterViewController:viewController];
    [self.pageViewController setViewControllers:@[nextViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)moveToLeftFrom:(KBNProjectDetailViewController *)viewController {
    
    if (viewController.pageIndex == 0) return;
    
    KBNProjectDetailViewController *nextViewController = (KBNProjectDetailViewController*)[self pageViewController:self.pageViewController viewControllerBeforeViewController:viewController];
    [self.pageViewController setViewControllers:@[nextViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];

}

- (void)moveToRightTask:(KBNTask *)task from:(KBNProjectDetailViewController *)viewController {
    
    NSUInteger index = 0;
    for (KBNTaskList* list in self.projectLists) {
        if ([list.taskListId isEqualToString:task.taskList.taskListId]) {
            break;
        }
        index++;
    }
    
    if (index < self.projectLists.count - 1) {
        [self moveTask:task toList:[self.projectLists objectAtIndex:++index]];
    }
}

- (void)moveToLeftTask:(KBNTask *)task from:(KBNProjectDetailViewController *)viewController {
    
    NSUInteger index = 0;
    for (KBNTaskList* list in self.projectLists) {
        if ([list.taskListId isEqualToString:task.taskList.taskListId]) {
            break;
        }
        index++;
    }
    
    if (index > 0) {
        [self moveTask:task toList:[self.projectLists objectAtIndex:--index]];
    }

}

- (void)moveTask:(KBNTask*)task toList:(KBNTaskList*)taskList {
    
    task.taskList = taskList;
    
    [[KBNTaskServiceOld sharedInstance] moveTask:task toList:taskList success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
    }];
}

- (void)toggleScrollStatus {
    self.scrollView.scrollEnabled = !self.scrollView.scrollEnabled;
}

#pragma mark - Add Task View Controller delegate

-(void)didCreateTask:(KBNTask *)task {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.projectTasks];
    [temp addObject:task];
    self.projectTasks = temp;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/

@end
