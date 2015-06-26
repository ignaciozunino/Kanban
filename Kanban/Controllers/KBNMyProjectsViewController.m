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
#import "KBNReachabilityWidgetView.h"
#import "KBNReachabilityUtils.h"

#define TABLEVIEW_PROJECT_CELL @"ProjectCell"
#define SEGUE_PROJECT_DETAIL @"projectDetail"
#define SEGUE_SELECT_PROJECT_TEMPLATE @"selectTemplate"
#define DELETE_WARNING_MESSAGE @"The selected project will be deleted"

#define PROJECT_ROW_HEIGHT 80

@interface KBNMyProjectsViewController () 

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *projects;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet KBNReachabilityWidgetView *reachabilityView;

@end

@implementation KBNMyProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.projects = [NSMutableArray new];
    
    [self getProjects];
    [self subscribeToNotifications];
}

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectUpdate:) name:UPDATE_PROJECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateProject:) name:PROJECT_ADDED object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Handlers

-(void)onProjectUpdate:(NSNotification *)notification{
    
    KBNProject *updatedProject = (KBNProject*)notification.object;
    
    NSUInteger index = 0;
    for (KBNProject* project in self.projects) {
        if ([project.projectId isEqualToString:updatedProject.projectId]) {
            [self.projects replaceObjectAtIndex:index withObject:updatedProject];
            break;
        }
        index++;
    }
    
    if (index == self.projects.count) {
        // The updated project isn't in the array. Add it.
        [self.projects addObject:updatedProject];
    }
    
    [self.tableView reloadData];
}

-(void) didCreateProject:(NSNotification *)notification {
    KBNProject *project = (KBNProject*)notification.object;
    [self.projects addObject:project];
    [self.tableView reloadData];
}

#pragma mark - Private methods

- (void)getProjects {
    __weak typeof(self) weakself = self;
    [[KBNProjectService sharedInstance] getProjectsOnSuccessBlock:^(NSArray *records) {
        weakself.projects = [NSMutableArray arrayWithArray:records];
        [weakself.tableView reloadData];
        
        // Start listening for updates
        [[KBNUpdateManager sharedInstance] listenToProjects:records];

    } errorBlock:^(NSError *error) {
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
    cell.layer.shadowOffset = CGSizeMake(-1, 1);
    cell.layer.shadowOpacity = 0.5;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([KBNReachabilityUtils isOffline]) {
        [self.reachabilityView showAnimated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    [self performSegueWithIdentifier:SEGUE_PROJECT_DETAIL sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([KBNReachabilityUtils isOffline]) {
        [self.reachabilityView showAnimated:YES];
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([KBNReachabilityUtils isOffline]) {
        [self.reachabilityView showAnimated:YES];
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.selectedIndexPath = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:DELETE_WARNING_MESSAGE
                                                       delegate:self
                                              cancelButtonTitle:CANCEL_TITLE
                                              otherButtonTitles:DELETE_TITLE, nil];
        [alert show];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PROJECT_ROW_HEIGHT;
}

#pragma mark - IBActions
- (IBAction)addProject:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:SEGUE_SELECT_PROJECT_TEMPLATE sender:sender];
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
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex) {
        [self removeProject];
    } else {
        [self.tableView setEditing:NO];
    }
}
#pragma mark - Helper methods

- (void)removeProject {
    
    NSUInteger index = self.selectedIndexPath.row;
    
    KBNProject *projectToDelete = [self.projects objectAtIndex:index];
    
    //First remove it from data source
    [self.projects removeObjectAtIndex:index];
    
    //Animate deletion
    [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:YES];
    
    // Then ask the service to remove it from the storage
    [[KBNProjectService sharedInstance] removeProject:projectToDelete
                                      completionBlock:^{
                                          // Project removed
                                      } errorBlock:^(NSError *error) {
                                          // Re-insert project at its original position
                                          __weak typeof(self) weakself = self;
                                          [weakself.projects insertObject:projectToDelete atIndex:index];
                                          [weakself.tableView insertRowsAtIndexPaths:@[weakself.selectedIndexPath] withRowAnimation:YES];
                                          
                                          [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
                                      }];
    
}

@end
