//
//  KBNProjectTemplate.h
//  Kanban
//
//  Created by Marcelo Dessal on 5/26/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KBNProjectTemplate : NSManagedObject

@property (nonatomic, strong) NSString *projectTemplateId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id lists;
@property (nonatomic, strong) NSDate *updatedAt;

@end
