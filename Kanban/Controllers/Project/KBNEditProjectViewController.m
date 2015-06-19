//
//  EditProjectViewController.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNEditProjectViewController.h"
#import "UITextView+CustomTextView.h"
#import "KBNReachabilityUtils.h"
#import "KBNReachabilityWidgetView.h"

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
@property (strong, nonatomic) IBOutlet UITableView *usersTableView;
@property (weak, nonatomic) IBOutlet KBNReachabilityWidgetView *reachabilityView;

@property (strong, nonatomic) MBProgressHUD* HUD;
@property (strong, nonatomic) MBProgressHUD* HUDInvite;

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
    
    if ([KBNReachabilityUtils isOffline]) {
        [self.reachabilityView showAnimated:YES];
        return;
    }
    
    [self startHUD];
    [[KBNProjectService sharedInstance] editProject:self.project withNewName:self.nameTextField.text withDescription:self.descriptionTextView.text completionBlock:^{
    } errorBlock:^(NSError *error) {
        [KBNAlertUtils showAlertView:[error localizedDescription] andType:ERROR_ALERT];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


- (IBAction)onInviteUserPressed:(id)sender {
    
    if ([KBNReachabilityUtils isOffline]) {
        [self.reachabilityView showAnimated:YES];
        return;
    }

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
    [self startHUDInvite];
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
                                                     }
                                                       onError:^(NSError* error){
                                                           [KBNAlertUtils showAlertView:ALERT_MESSAGE_INVITE_FAILED andType:ERROR_ALERT];
                                                       }];
                                }
                                     errorBlock:^(NSError *error) {
                                         [KBNAlertUtils showAlertView:[error.userInfo objectForKey:NSLocalizedDescriptionKey] andType:ERROR_ALERT];
                                     }];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *projectUsers = (NSArray*)self.project.users;
    return projectUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLEVIEW_USERSLIST_CELL forIndexPath:indexPath];
    NSString* userEmail = [self.project.users objectAtIndex:indexPath.row];
    cell.textLabel.text = userEmail;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HUD

- (void)startHUD {
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.HUD.dimBackground = YES;
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    self.HUD.labelText = EDIT_PROJECT_LOADING;
    [self.HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    self.HUD.delegate = self;
}

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.040f;
        self.HUD.progress = progress;
        usleep(50000);
    }
    sleep(0.7);
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    self.HUD.customView = imageView;
    self.HUD.mode = MBProgressHUDModeCustomView;
    self.HUD.labelText = PROJECT_EDIT_SUCCESS;
    sleep(1);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startHUDInvite {
    self.HUDInvite = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUDInvite];
    self.HUDInvite.dimBackground = YES;
    self.HUDInvite.mode = MBProgressHUDModeAnnularDeterminate;
    self.HUDInvite.labelText = EDIT_PROJECT_INVITING;
    [self.HUDInvite showWhileExecuting:@selector(myProgressTaskInvite) onTarget:self withObject:nil animated:YES];
    self.HUDInvite.delegate = self;
}

- (void)myProgressTaskInvite {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.040f;
        self.HUDInvite.progress = progress;
        usleep(50000);
    }
    sleep(0.7);
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    self.HUDInvite.customView = imageView;
    self.HUDInvite.mode = MBProgressHUDModeCustomView;
    self.HUDInvite.labelText = ALERT_MESSAGE_INVITE_SENT_SUCCESSFULY;
    sleep(1);
}
@end
