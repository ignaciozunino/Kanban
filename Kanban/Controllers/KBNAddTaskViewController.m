//
//  AddTaskViewController.m
//  Kanban
//
//  Created by Marcelo Dessal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNAddTaskViewController.h"
#import "KBNConstants.h"
#import "KBNAlertUtils.h"
#import "KBNTaskService.h"

@interface KBNAddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@end

@implementation KBNAddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)save:(UIBarButtonItem *)sender {
    
    self.addTask.name = self.nameTextField.text;
    self.addTask.taskDescription = self.descriptionTextField.text;
    NSNumber* taskListCount = [NSNumber numberWithInt:(int)[self.taskListTasks count]];
    __weak typeof(self) weakself = self;

     [[KBNTaskService sharedInstance] createTaskWithName:self.addTask.name taskDescription:self.addTask.taskDescription order:[self getOrderNumber] projectId:self.addTask.project.projectId taskListId:self.addTask.taskList.taskListId taskListCount:taskListCount completionBlock:^(NSDictionary *response) {
        
        weakself.addTask.taskId = [response objectForKey:PARSE_OBJECTID];
        [weakself.delegate didCreateTask:weakself.addTask];
        [weakself dismissViewControllerAnimated:YES completion:nil];
        
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT];
        [weakself dismissViewControllerAnimated:YES completion:nil];
        
    }];
}

- (NSNumber*)getOrderNumber {
    return [self.delegate nextOrderNumber];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
