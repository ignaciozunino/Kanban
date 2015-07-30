//
//  ProjectUtils.m
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProjectUtils.h"
#import "KBNAppDelegate.h"
#import "KBNConstants.h"
#import "NSDate+Utils.h"

@implementation KBNProjectUtils

+ (KBNProject *)projectWithParams:(NSDictionary *)params {
    return [[KBNCoreDataManager sharedInstance] projectWithParams:params];
}

+ (NSDictionary *)projectJson:(KBNProject *)project {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            project.projectId, PARSE_OBJECTID,
            project.name, PARSE_PROJECT_NAME_COLUMN,
            project.projectDescription, PARSE_PROJECT_DESCRIPTION_COLUMN,
            project.users, PARSE_PROJECT_USERSLIST_COLUMN   ,
            project.active, PARSE_PROJECT_ACTIVE_COLUMN, nil];
}

+ (NSDictionary *)projectsJson:(NSArray *)projects {
    
    NSMutableArray *objects = [NSMutableArray array];
    
    for (KBNProject *project in projects) {
        [objects addObject:[self projectJson:project]];
    }
    
    return [NSDictionary dictionaryWithObject:objects forKey:@"results"];
}

+ (NSArray *)projectsFromDictionary:(NSDictionary *)records key:(NSString *)key {

    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary* params in (NSArray*)[records objectForKey:key]) {
        KBNProject *project = [self projectWithParams:params];
        [array addObject:project];
    }
    return array;
}

+ (KBNProject *)projectFromId:(NSString *)projectId {
    return [[KBNCoreDataManager sharedInstance] projectFromId:projectId];
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
