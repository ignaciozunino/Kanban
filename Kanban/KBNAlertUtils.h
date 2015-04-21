//
//  AlertUtils.h
//  Kanban
//
//  Created by Maxi Casal on 4/17/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KBNConstants.h"

@interface KBNAlertUtils : NSObject

+ (void)showAlertView:(NSString*) message andType: (NSString*) alerType;

@end
