//
//  AlertUtils.m
//  Kanban
//
//  Created by Maxi Casal on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "AlertUtils.h"

@implementation AlertUtils

+ (void) showAlertView:(NSString*) message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
