//
//  KBNTutorialPageViewController.m
//  Kanban
//
//  Created by Maxi Casal on 6/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNTutorialPageViewController.h"
#import "KBNTutorialContentViewController.h"

@interface KBNTutorialPageViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageActions;
@property (strong, nonatomic) NSArray *pageImages;

@end

@implementation KBNTutorialPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTutorialData];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    KBNTutorialContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = self.view.frame;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)setupTutorialData {
    self.pageActions = @[@"Create Projects", @"Create and move tasks", @"Invite users"];
    self.pageImages = @[@"tutorial1.png", @"tutorial2.png", @"tutorial3.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KBNTutorialContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((KBNTutorialContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageActions count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (KBNTutorialContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageActions count] == 0) || (index >= [self.pageActions count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    KBNTutorialContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KBNTutorialContentViewController"];
    pageContentViewController.imageName = self.pageImages[index];
    pageContentViewController.actionName = self.pageActions[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageActions count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
