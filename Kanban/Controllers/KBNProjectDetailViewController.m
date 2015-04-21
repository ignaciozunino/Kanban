//
//  ProjectDetailViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectDetailViewController.h"
#import "KBNAppDelegate.h"
#import "KBNTaskDetailViewController.h"

#define TABLEVIEW_TASK_CELL @"TaskCell"
#define SEGUE_TASK_DETAIL @"taskDetail"


@interface KBNProjectDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation KBNProjectDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.project.name;
    self.labelState.text = [taskStates objectAtIndex:self.pageIndex];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tasks count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_TASK_CELL forIndexPath:indexPath];
    
    KBNTask* task = [self.tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = task.name;
    
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
    
    if ([[segue identifier] isEqualToString:SEGUE_TASK_DETAIL]) {
        KBNTaskDetailViewController *controller = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        controller.task = [self.tasks objectAtIndex:indexPath.row];
        
    }
}


@end
