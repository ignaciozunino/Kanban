//
//  KBNUpdateManager.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNUpdateManager.h"

@interface KBNUpdateManager ()
@property (nonatomic,unsafe_unretained) BOOL shouldUpdateTasks;
@property (nonatomic,unsafe_unretained) BOOL shouldUpdateProjects;
@property (nonatomic,strong) NSDate *lastProjectSyncDate;
@property (nonatomic,strong) NSDate *lastTasksSyncDate;
@property NSString * lastProjectsUpdate;
@end

@implementation KBNUpdateManager


-(void)startUpdatingProjects{
    self.shouldUpdateProjects = YES;
    self.lastProjectsUpdate = [NSDate getUTCNow];
    [self updateLastProjectUpdateDate];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateProjects];
    });
}

-(void)startUpdatingTasks{

    self.shouldUpdateTasks= YES;
   
    
}

-(void)stopUpdatingProjects{
    self.shouldUpdateProjects = NO;
    
}

-(void)stopUpdatingTasks{
    
    self.shouldUpdateTasks= NO;
    
}

-(void)updateProjects{
    if (self.shouldUpdateProjects) {
        //query
        //completionblock
        //{
        //if (upated){
        [self postNotification:KBNProjectsUpdated];
        //}
        dispatch_after(KBNTimeBetweenUpdates, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self updateProjects];
        });
    }
}

- (void)postNotification:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

- (void)dealloc
{
   // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateLastProjectUpdateDate{
   
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.updatedDate == %@.@min.updatedDate",self.updatedProjects];
        NSArray * array = [self.updatedProjects filteredArrayUsingPredicate:predicate];
        if(array.count > 0){
         //self.lastProjectSyncDate = (NSProject*)array[0].updatedDate ;
        }
    
}


@end
