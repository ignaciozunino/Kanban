//
//  KBNProjectTemplateUtils.m
//  Kanban
//
//  Created by Marcelo Dessal on 5/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectTemplateUtils.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"

@implementation KBNProjectTemplateUtils

+ (KBNProjectTemplate *)projectTemplateWithParams:(NSDictionary *)params {
    return [[KBNCoreDataManager sharedInstance] projectTemplateWithParams:params];
}

+ (KBNProjectTemplate *)defaultTemplate {
 
    return [[KBNCoreDataManager sharedInstance] projectTemplateWithParams:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"DEFAULT", nil), @"name", DEFAULT_TASK_LISTS, @"lists", @"xxxxxxxxxx", PARSE_OBJECTID, nil]];
}

@end
