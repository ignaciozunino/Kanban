//
//  ProjectPageViewController.m
//  Kanban
//
//  Created by Lucas on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectPageViewController.h"
#import "KBNAppDelegate.h"

@interface KBNProjectPageViewController ()

@end

@implementation KBNProjectPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.title = self.project.name;
    
    self.states = taskStates;
    
    [self getTasks];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:PAGE_VC];
    self.pageViewController.dataSource = self;
    KBNProjectDetailViewController* startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

#pragma mark - Private methods

- (void)getTasks {
    
    //For now this method is for testing purposes. Sooner it will get tasks from the database
    
    NSMutableArray *tasksArray = [[NSMutableArray alloc] init];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"tasks" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSArray *projectList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    for (NSDictionary* item in projectList) {
        KBNTask *newTask = [[KBNTask alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_TASK
                                                                          inManagedObjectContext:self.managedObjectContext]
                               insertIntoManagedObjectContext:self.managedObjectContext];
        
        newTask.name = [item objectForKey:@"name"];
        newTask.taskDescription = [item objectForKey:@"description"];
        newTask.state = [item objectForKey:@"state"];
        
        KBNProject *project = [[KBNProject alloc]initWithEntity:[NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
        
        project.name = [item objectForKey:@"project"];
        
        newTask.project = project;
        
        if ([project.name isEqualToString:self.project.name]) {
            [tasksArray addObject:newTask];
        }
        
    }
    
    self.tasks = tasksArray;
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
    if (index == [self.states count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

-(KBNProjectDetailViewController*)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.states count] == 0) || (index >= [self.states count]))
    {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    KBNProjectDetailViewController *projectDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:PROJECT_DETAIL_VC];

    projectDetailViewController.pageIndex = index;
    projectDetailViewController.tasks = [self tasksForState:(int)index];
    
    return projectDetailViewController;
}

-(NSArray*)tasksForState:(TaskState)state
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (KBNTask* task in self.tasks) {
        if ([task.state intValue] == state){
            [result addObject:task];
        }
    }
    return result;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.states count];
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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
