//
//  EditProjectViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEditProjectViewController.h"
#import "UITextView+CustomTextView.h"

#define TABLEVIEW_TASKLIST_CELL @"stateCell"

#define TABLEVIEW_USERSLIST_CELL @"usersListCell"

//Alert messages
#define ALERT_MESSAGE_EMAIL_FORMAT_NOT_VALID @"The format of the email address entered is not valid"
#define ALERT_MESSAGE_INVITE_SENT_SUCCESSFULY @"Email sent successfuly!"
#define ALERT_MESSAGE_INVITE_FAILED @"Sorry, the invite could not be sent at this time. Try again later"
#define ALERT_MESSAGE_INVITE_PROMPT_TITLE @"Invite User"
#define ALERT_MESSAGE_INVITE_PROMPT_MESSAGE @"Enter the email address"
#define ALERT_MESSAGE_INVITE_PROMPT_INVITEBUTTONTITLE @"Invite"
#define ALERT_MESSAGE_INVITE_PROMPT_CANCELBUTTONTITLE @"Cancel"


@interface KBNEditProjectViewController()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIView *activityIndicatorBackground;
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
@end


@implementation KBNEditProjectViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadProjectAttributes];
    self.navigationItem.title = @"Edit Project";
    
    [self.view setBackgroundColor:UIColorFromRGB(LIGHT_GRAY)];
    [self.descriptionTextView setBorderWithColor:[UIColorFromRGB(BORDER_GRAY) CGColor]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)loadProjectAttributes {
    self.nameTextField.text = self.project.name;
    self.descriptionTextView.text = self.project.projectDescription;
}

#pragma mark - IBActions

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onCancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)onSavePressed:(id)sender {
    [KBNAppDelegate activateActivityIndicator:YES];
    [[KBNProjectService sharedInstance] editProject:self.project withNewName:self.nameTextField.text withDescription:self.descriptionTextView.text completionBlock:^{
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:PROJECT_EDIT_SUCCESS andType:SUCCESS_ALERT];
        [self dismissViewControllerAnimated:YES completion:nil];

    } errorBlock:^(NSError *error) {
        [KBNAppDelegate activateActivityIndicator:NO];
        [KBNAlertUtils showAlertView:[error localizedDescription ]andType:ERROR_ALERT ];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


- (IBAction)onInviteUserPressed:(id)sender {
    //Show a simple UIAlertView with a text box.
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:ALERT_MESSAGE_INVITE_PROMPT_TITLE message:ALERT_MESSAGE_INVITE_PROMPT_MESSAGE delegate:self cancelButtonTitle:ALERT_MESSAGE_INVITE_PROMPT_CANCELBUTTONTITLE otherButtonTitles:ALERT_MESSAGE_INVITE_PROMPT_INVITEBUTTONTITLE,nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (!buttonIndex){
        return;
    }
    NSString* title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Invite"]){
        UITextField * emailTextField = [alertView textFieldAtIndex:0];
        NSString* emailAddress = emailTextField.text;
        if ([KBNUserUtils isValidUsername:emailAddress]){
            [self sendInviteTo:emailAddress];
        }else{
            [KBNAlertUtils showAlertView:ALERT_MESSAGE_EMAIL_FORMAT_NOT_VALID andType:ERROR_ALERT];
        }
    }
}

-(void) sendInviteTo:(NSString*)emailAddress{
    //Add the user to the project. If the update goes well then send the email with the invite.
    __weak typeof(self) weakSelf = self;
    [self enableActivityIndicator];
    [[KBNProjectService sharedInstance] addUser:emailAddress
                                      toProject:self.project
                                completionBlock:^{
                                    
                                    [KBNEmailUtils sendEmailTo:emailAddress
                                                          from:[KBNUserUtils getUsername]
                                                       subject:EMAIL_INVITE_SUBJECT
                                                          body:[NSString stringWithFormat:@"%@ Link: %@%@",EMAIL_INVITE_BODY,WEBSITE_BASE_URL,self.project.projectId]
                                                     onSuccess:^(){
                                                         //Refresh the table view
                                                         [weakSelf.usersTableView reloadData];
                                                         //Let the user know everything went OK...
                                                         [KBNAlertUtils showAlertView:ALERT_MESSAGE_INVITE_SENT_SUCCESSFULY andType:SUCCESS_ALERT];
                                                         [weakSelf disableActivityIndicator];
                                                     }
                                                       onError:^(NSError* error){
                                                           [weakSelf disableActivityIndicator];
                                                           [KBNAlertUtils showAlertView:ALERT_MESSAGE_INVITE_FAILED andType:ERROR_ALERT];
                                                       }];
                                }
                                     errorBlock:^(NSError *error) {
                                         [KBNAlertUtils showAlertView:[error.userInfo objectForKey:@"NSLocalizedDescriptionKey"] andType:ERROR_ALERT];
                                         [weakSelf disableActivityIndicator];
                                     }];
}

#pragma mark - Activity indicator on/off
-(void) enableActivityIndicator{
    self.activityIndicatorBackground.hidden = NO;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

-(void) disableActivityIndicator{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    self.activityIndicatorBackground.hidden = YES;
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.project.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_USERSLIST_CELL forIndexPath:indexPath];
    NSString* userEmail = [self.project.users objectAtIndex:indexPath.row];
    cell.textLabel.text = userEmail;
    //cell.textLabel.font = [UIFont getTableFont];
    //cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
