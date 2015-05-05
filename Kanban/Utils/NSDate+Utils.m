//
//  NSDate+Utils.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

+(NSString *)getUTCNow
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"YYYY-MM-DDTHH:MM:SS.MMMZ"];
    NSString *dateString = [dateFormatter stringFromDate:[[NSDate alloc]init]];
    
    return dateString;
}

@end
