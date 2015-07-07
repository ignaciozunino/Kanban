//
//  SignInViewController.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBNUser.h"
#import "KBNUserService.h"
#import "KBNConstants.h"
#import "KBNUserUtils.h"
#import "KBNAlertUtils.h"
#import "KBNErrorUtils.h"
#import "MBProgressHUD.h"

@interface KBNSignInViewController : UIViewController <UIAlertViewDelegate, MBProgressHUDDelegate>

@end
