//
//  MyProjectsViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNMyProjectsViewController.h"
#import "KBNProjectPageViewController.h"
#import "KBNAppDelegate.h"
#import "KBNTaskService.h"
#import "KBNAlertUtils.h"
#import "KBNUpdateManager.h"

#define TABLEVIEW_PROJECT_CELL @"ProjectCell"
#define SEGUE_PROJECT_DETAIL @"projectDetail"
#define SEGUE_ADD_PROJECT @"addProject"

#define PROJECT_ROW_HEIGHT 80

@interface KBNMyProjectsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *projects;

@end

@implementation KBNMyProjectsViewController

- (void)listenUpdateManager {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectsUpdate:) name:KBNProjectsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectsUpdate:) name:KBNProjectsInitialUpdate object:nil];
    [[KBNUpdateManager sharedInstance] startUpdatingProjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.projects=[NSMutableArray new];
    [self listenUpdateManager];
}

- (void)stopListeningUpdateManager
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[KBNUpdateManager sharedInstance] stopUpdatingProjects];
}

- (void) dealloc
{
    [self stopListeningUpdateManager];
}

-(void)onProjectsUpdate:(NSNotification *)noti{
    
    [self getProjects:noti];
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)getProjects:(NSNotification *)noti {
    [KBNUpdateUtils updateExistingProjectsFromArray:(NSArray*)noti.object inArray:self.projects];
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [KBNAppDelegate activateActivityIndicator:YES];
        [weakself.tableView reloadData];
        
        [KBNAppDelegate activateActivityIndicator:NO];
    });
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_PROJECT_CELL forIndexPath:indexPath];
    KBNProject *project = [self.projects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = project.name;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PROJECT_ROW_HEIGHT;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:SEGUE_PROJECT_DETAIL]) {
        KBNProjectPageViewController *controller = [segue destinationViewController];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        controller.project = [self.projects objectAtIndex:indexPath.row];
    }
    if ([segue.identifier isEqualToString:SEGUE_ADD_PROJECT]) {
        UINavigationController *navController = [segue destinationViewController];
        KBNAddProjectViewController *controller   = (KBNAddProjectViewController*) navController.topViewController;
        controller.projectService = [KBNProjectService sharedInstance];
        controller.delegate = self;
    }
}

#pragma mark - KBNAddProject Delegate
-(void) didCreateProject:(KBNProject *)project{
    [self.projects addObject:project];
    [KBNUpdateManager sharedInstance].lastProjectsUpdate = [NSDate getUTCNowWithParseFormat];
    [self.tableView reloadData];
}
@end
