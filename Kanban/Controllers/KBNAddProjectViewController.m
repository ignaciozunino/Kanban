//
//  AddProjectViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNAddProjectViewController.h"
#import "KBNProjectTemplateService.h"
#import "KBNProjectTemplateUtils.h"
#import "UITextView+CustomTextView.h"

#define TEMPLATE_CELL @"TemplateCell"

@interface KBNAddProjectViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *templates;
@property (strong, nonatomic) KBNProjectTemplate *selectedTemplate;

@end

@implementation KBNAddProjectViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
    [self.descriptionTextView setBorderWithColor:[UIColorFromRGB(BORDER_GRAY) CGColor]];
    
    self.templates = [NSMutableArray arrayWithObject:[KBNProjectTemplateUtils defaultTemplate]];
    self.selectedTemplate = [self.templates objectAtIndex:0];
    
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

- (instancetype)initWithService:(KBNProjectService *) projectService{
    
    self = [super init];
    
    if (self) {
        _projectService = projectService;
    }
    return self;
}

#pragma mark - IBActions

- (IBAction)save:(UIBarButtonItem *)sender {
    [KBNAppDelegate activateActivityIndicator:YES];
    __weak typeof(self) weakself = self;
    [self.projectService createProject:self.nameTextField.text withDescription:self.descriptionTextView.text forUser:[KBNUserUtils getUsername] withTemplate:self.selectedTemplate completionBlock:^(KBNProject *project) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:PROJECT_CREATION_SUCCESS andType:SUCCESS_ALERT];
        
        [weakself.delegate didCreateProject:project];
        [weakself dismissViewControllerAnimated:YES completion:nil];

    } errorBlock:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma  mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.templates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEMPLATE_CELL forIndexPath:indexPath];
    
    cell.textLabel.text = [[self.templates objectAtIndex:indexPath.row] name];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedTemplate = [self.templates objectAtIndex:indexPath.row];
    
}


@end
