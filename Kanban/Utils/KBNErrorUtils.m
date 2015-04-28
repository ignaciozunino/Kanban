//
//  KBNErrorUtils.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNErrorUtils.h"

@implementation KBNErrorUtils


+(NSString *) getErrorMessage: (NSInteger) code{
    switch (code) {
        case -101:
            return SIGNIN_ERROR;
            break;
            
        default:
            return @"Unknown Error";
            break;
    }
}
@end
