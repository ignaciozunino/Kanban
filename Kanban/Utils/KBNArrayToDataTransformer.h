//
//  KBNArrayToDataTransformer.h
//  Kanban
//
//  Created by Lucas on 5/11/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBNArrayToDataTransformer : NSValueTransformer
+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;
- (id)reverseTransformedValue:(id)value;
@end