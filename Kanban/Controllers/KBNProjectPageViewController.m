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
#import "KBNUpdateManager.h"

#define KBNEDIT_VC @"KBNEditProjectViewController"


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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(setupEdit)];
    // [self getProjectLists];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTasksUpdate) name:KBNTasksUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCurrentProjectUpdate) name:KBNCurrentProjectUpdated object:nil];
    [KBNAppDelegate activateActivityIndicator:YES];
    [self getProjectLists];
}

- (void) dealloc
{
    [[KBNUpdateManager sharedInstance] stopUpdatingTasks];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data methods
-(void)onTasksUpdate{
    
   [self getProjectTasks];
    [KBNAppDelegate activateActivityIndicator:NO];
    
    
}
-(void)onCurrentProjectUpdate{
    
    self.project = [KBNUpdateManager sharedInstance].projectForTasksUpdate;
    self.title = self.project.name;
}

- (void)getProjectLists {
    __weak typeof(self) weakself = self;
    
    [[KBNTaskListService sharedInstance] getTaskListsForProject:self.project.projectId completionBlock:^(NSDictionary *response) {
        
        NSMutableArray *taskLists = [[NSMutableArray alloc] init];
        
        for (NSDictionary* params in [response objectForKey:@"results"]) {
            [taskLists addObject:[KBNTaskListUtils taskListForProject:self.project params:params]];
        }
        
        weakself.projectLists = taskLists;
        [[KBNUpdateManager sharedInstance] startUpdatingTasksForProject:self.project];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Error getting TaskLists: %@",error.localizedDescription);
    }];
}

- (void)getProjectTasks {
    self.projectTasks = [KBNUpdateManager sharedInstance].updatedTasks;
    
    [self createPageViewController];
  
}

#pragma mark - Controller methods

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
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
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
    
    [[KBNTaskService sharedInstance] moveTask:task.taskId toList:taskList.taskListId completionBlock:^(NSDictionary *response) {
        //
    } errorBlock:^(NSError *error) {
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

- (void)setupEdit {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KBNEditProjectViewController *vc = [storyboard instantiateViewControllerWithIdentifier:KBNEDIT_VC];
    vc.project = self.project;
    vc.projectId = self.project.projectId;        
    [self.navigationController pushViewController:vc animated:YES];
}
/*
 //
 //  PRSurveyMenuButtonView.m
 //  Briefcase
 //
 //  Created by Luciano Castro  on 6/16/14.
 //  Copyright (c) 2014 Pernod Ricard. All rights reserved.
 //
 
 #import "PRSurveyMenuButtonView.h"
 #import "PRSurveyUploadsViewController.h"
 #import "PRSurveyManager.h"
 
 @implementation PRSurveyMenuButtonView
 
 - (id)initWithFrame:(CGRect)frame
 {
 self = [super initWithFrame:frame];
 if (self) {
 // Initialization code
 }
 return self;
 }
 
 
 - (id)initWithCoder:(NSCoder *)aDecoder
 {
 self = [super initWithCoder:aDecoder];
 if (self)
 {
 //Add update manager notifications to handle UI feedback
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSurveyManagerDidStartUpdate) name:PRSurveyManagerDidStartSubmittingSurveyNotification object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSurveyManagerDidEndUpdate) name:PRSurveyManagerDidFinishSubmittingAllSurveysNotification object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSurveyManagerDidStopUpdating) name:PRSurveyMAnagerDidStopNotification object:nil];
 }
 return self;
 }
 
 - (void) onSurveyManagerDidStartUpdate
 {
 [self.activityIndicator startAnimating];
 }
 
 - (void) onSurveyManagerDidEndUpdate
 {
 [self.activityIndicator stopAnimating];
 }
 
 - (void) onSurveyManagerDidStopUpdating
 {
 [self.activityIndicator stopAnimating];
 }
 
 - (IBAction)onShowPopup:(id)sender
 {
 if (self.popOver != nil)
 {
 [self.popOver dismissPopoverAnimated:NO];
 }
 
 PRSurveyUploadsViewController *surveyList = [[PRSurveyUploadsViewController alloc] initWithNibName:nil bundle:nil];
 
 surveyList.contentSizeForViewInPopover = surveyList.view.size;
 
 UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:surveyList];
 
 self.popOver = popover;
 
 [self.popOver presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
 }
 
 - (void) dealloc
 {
 [[NSNotificationCenter defaultCenter] removeObserver:self];
 }
 */

@end

