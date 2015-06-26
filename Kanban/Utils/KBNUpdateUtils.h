//
//  KBNUpdateUtils.h
//  Kanban
//
//  Created by Guillermo Apoj on 8/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProject.h"
#import "KBNTask.h"
#import "KBNTaskList.h"
#import "KBNTaskUtils.h"
#import "KBNConstants.h"
#import "KBNUserUtils.h"
#import <Firebase/Firebase.h>
#import "KBNUserUtils.h"

typedef NS_ENUM(NSInteger, KBNChangeType) {
    KBNChangeTypeProjectUpdate,
    KBNChangeTypeTaskListUpdate,
    KBNChangeTypeTaskUpdate,
    KBNChangeTypeTasksUpdate,
    KBNChangeTypeTaskAdd,
    KBNChangeTypeTaskMove
};

@interface KBNUpdateUtils : NSObject

+ (void)postToFirebase:(Firebase *)rootReference changeType:(KBNChangeType)changeType projectId:(NSString*)projectId data:(id)data;

@end
