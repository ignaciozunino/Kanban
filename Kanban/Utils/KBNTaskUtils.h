//
//  KBNTaskUtils.h
//  Kanban
//
//  Created by Marcelo Dessal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNTask.h"

@interface KBNTaskUtils : NSObject

+ (KBNTask*)taskForProject:(KBNProject*)project taskList:(KBNTaskList*)taskList params:(NSDictionary*)params;

@end
