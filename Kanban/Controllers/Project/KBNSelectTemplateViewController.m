//
//  KBNSelectTemplateViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 6/1/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNSelectTemplateViewController.h"
#import "KBNProjectTemplateService.h"
#import "KBNProjectTemplateUtils.h"
#import "KBNAlertUtils.h"
#import "KBNReachabilityUtils.h"
#import "KBNReachabilityWidgetView.h"

#define TEMPLATE_CELL @"TemplateCell"
#define TEMPLATE_ROW_HEIGHT 80

#define SEGUE_ADD_PROJECT @"addProject"

@interface KBNSelectTemplateViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet KBNReachabilityWidgetView *reachabilityView;

@property (strong, nonatomic) NSMutableArray *templates;

@end

@implementation KBNSelectTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
    
    self.templates = [NSMutableArray arrayWithObject:[KBNProjectTemplateUtils defaultTemplate]];
    
    [self getMoreTemplates];
}

- (void)getMoreTemplates {
    __weak typeof(self) weakself = self;
    [[KBNProjectTemplateService sharedInstance] getTemplatesCompletionBlock:^(NSArray *templates) {
        [weakself.templates addObjectsFromArray:templates];
        [weakself.tableView reloadData];
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma  mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.templates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEMPLATE_CELL forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.templates objectAtIndex:indexPath.row] name];
    cell.layer.shadowOffset = CGSizeMake(-1, 1);
    cell.layer.shadowOpacity = 0.5;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SEGUE_ADD_PROJECT sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TEMPLATE_ROW_HEIGHT;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    KBNAddProjectViewController *controller = (KBNAddProjectViewController*)[segue destinationViewController];
    NSUInteger index = [[self.tableView indexPathForSelectedRow] row];
    controller.selectedTemplate = [self.templates objectAtIndex:index];
    
}

@end
