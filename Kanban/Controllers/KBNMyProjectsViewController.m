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

@end

@implementation KBNMyProjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
   
}

-(void)viewWillAppear:(BOOL)animated{

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

    __weak typeof(self) weakself = self;
    [KBNAppDelegate activateActivityIndicator:YES];
    [[KBNProjectService sharedInstance]getProjectsOnSuccess:^(NSArray *records) {
        weakself.projects = records;
        dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.tableView reloadData];
        
        [KBNAppDelegate activateActivityIndicator:NO];
        });
    } errorBlock:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
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
    cell.textLabel.font = [UIFont getKBNTableFont];
    cell.textLabel.textColor = [UIColor whiteColor];

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
