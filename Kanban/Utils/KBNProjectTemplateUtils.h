//
//  KBNProjectTemplateUtils.h
//  Kanban
//
//  Created by Marcelo Dessal on 5/27/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNProjectTemplate.h"

@interface KBNProjectTemplateUtils : NSObject

+ (KBNProjectTemplate*)projectTemplateWithParams:(NSDictionary *)params;

+ (KBNProjectTemplate*)defaultTemplate;

@end
