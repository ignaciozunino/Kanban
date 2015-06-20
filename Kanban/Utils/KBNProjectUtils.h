//
//  ProjectUtils.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/20/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProject.h"

@interface KBNProjectUtils : NSObject

+ (KBNProject*)projectWithParams:(NSDictionary *)params;

@end
