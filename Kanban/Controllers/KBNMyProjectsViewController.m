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
#import "KBNTaskServiceOld.h"
#import "KBNTaskService.h"
#import "KBNAlertUtils.h"

#define TABLEVIEW_PROJECT_CELL @"ProjectCell"
#define SEGUE_PROJECT_DETAIL @"projectDetail"
#define SEGUE_ADD_PROJECT @"addProject"

@interface KBNMyProjectsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *projects;
@property (strong, nonatomic) NSArray *taskLists;

@end

@implementation KBNMyProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    [self getProjects];
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)getProjects {
    [[KBNTaskServiceOld sharedInstance] getProjectsOnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak typeof(self) weakself = self;
        NSMutableArray *projectsArray = [[NSMutableArray alloc] init];
        
        NSDictionary *projectList = [responseObject objectForKey:@"results"];
        
        for (NSDictionary* item in projectList) {
            KBNProject *newProject = [[KBNProject alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_PROJECT
                                                                                    inManagedObjectContext:weakself.managedObjectContext]
                                         insertIntoManagedObjectContext:weakself.managedObjectContext];
            
            newProject.projectId = [item objectForKey:PARSE_OBJECTID];
            newProject.name = [item objectForKey:PARSE_PROJECT_NAME_COLUMN];
            newProject.projectDescription = [item objectForKey:PARSE_PROJECT_DESCRIPTION_COLUMN];
            
            [projectsArray addObject:newProject];
        }
        
        weakself.projects = projectsArray;
        
        //[weakself addTaskListsToProjects];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
    }];
    
}

- (void)addTaskListsToProjects {
    
    [[KBNTaskServiceOld sharedInstance] getTaskListsOnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        __weak typeof(self) weakself = self;
        NSMutableArray *taskListsArray = [[NSMutableArray alloc] init];
        
        NSDictionary *lists = [responseObject objectForKey:@"results"];
        
        for (NSDictionary* item in lists) {
            KBNTaskList *newList = [[KBNTaskList alloc] initWithEntity:[NSEntityDescription entityForName:ENTITY_TASK_LIST inManagedObjectContext:self.managedObjectContext] insertIntoManagedObjectContext:self.managedObjectContext];
            
            newList.taskListId = [item objectForKey:PARSE_OBJECTID];
            newList.name = [item objectForKey:PARSE_TASKLIST_NAME_COLUMN];
            newList.order = [item objectForKey:PARSE_TASKLIST_ORDER_COLUMN];
            NSString* projectId = [item objectForKey:PARSE_TASKLIST_PROJECT_COLUMN];
            
            for (KBNProject* project in weakself.projects) {
                if ([project.projectId isEqualToString:projectId]) {
                    newList.project = project;
                    break;
                }
            }
            
            [taskListsArray addObject:newList];
        }
        
        weakself.taskLists = taskListsArray;
        [weakself.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
    }];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:SEGUE_PROJECT_DETAIL]) {
        KBNProjectPageViewController *controller = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        controller.project = [self.projects objectAtIndex:indexPath.row];
    }
    if ([segue.identifier isEqualToString:SEGUE_ADD_PROJECT]) {
        UINavigationController *navController = [segue destinationViewController];
        KBNAddProjectViewController *controller   = (KBNAddProjectViewController*) navController.topViewController;
        controller.projectService = [KBNProjectService sharedInstance];
    }
}


@end
