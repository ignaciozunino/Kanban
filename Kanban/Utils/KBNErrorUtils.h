//
//  KBNErrorUtils.h
//  Kanban
//
//  Created by Maximiliano Casal on 4/28/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBNConstants.h"

@interface KBNErrorUtils : NSObject

+(NSString*) getErrorMessage: (NSInteger) code;
@end
