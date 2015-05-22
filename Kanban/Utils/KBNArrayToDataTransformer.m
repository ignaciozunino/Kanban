//
//  KBNArrayToDataTransformer.m
//  Kanban
//
//  Created by Lucas on 5/11/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNArrayToDataTransformer.h"

@implementation KBNArrayToDataTransformer

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}


@end