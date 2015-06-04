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

- (void)listenUpdateManager {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectsUpdate:) name:KBNProjectsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectsUpdate:) name:KBNProjectsInitialUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProjectUpdate:) name:KBNProjectUpdate object:nil];

    [[KBNUpdateManager sharedInstance] startUpdatingProjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.projects=[NSMutableArray new];
    [self subscribeToNotifications];
    
}

- (void)subscribeToNotifications {
    
    [self listenUpdateManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateProject:) name:PROJECT_ADDED object:nil];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[KBNUpdateManager sharedInstance] startListeningProjects:self.projects];
    [self.tableView reloadData];
}

- (void)stopListeningUpdateManager
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[KBNUpdateManager sharedInstance] stopUpdatingProjects];
}

- (void) dealloc {
    
    [self stopListeningUpdateManager];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PROJECT_ADDED object:nil];

}

-(void)onProjectsUpdate:(NSNotification *)noti{
    
    [self getProjects:noti];
}

-(void)onProjectUpdate:(NSNotification *)notification{
    
    KBNProject *projectUpdated = (KBNProject*)notification.object;
    for (KBNProject* project in self.projects) {
        if ([project.projectId isEqualToString:projectUpdated.projectId]) {
            project.name = projectUpdated.name;
            break;
        }
    }
}

- (NSManagedObjectContext*) managedObjectContext {
    return [(KBNAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

- (void)getProjects:(NSNotification *)notification {
    [KBNUpdateUtils updateExistingProjectsFromArray:(NSArray*)notification.object inArray:self.projects];
    
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
    cell.layer.shadowOffset = CGSizeMake(-1, 1);
    cell.layer.shadowOpacity = 0.5;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    if ([KBNReachabilityUtils isOffline]) {
        [self.reachabilityView showAnimated:YES];
    } else {
        [self performSegueWithIdentifier:SEGUE_SELECT_PROJECT_TEMPLATE sender:sender];
    }
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

#pragma mark - Add Project Notification
-(void) didCreateProject:(NSNotification *)notification {
    KBNProject *project = (KBNProject*)notification.object;
    [self.projects addObject:project];
    [KBNUpdateManager sharedInstance].lastProjectsUpdate = [NSDate getUTCNowWithParseFormat];
    [self.tableView reloadData];
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
