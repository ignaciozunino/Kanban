//
//  NSDate+Utils.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/5/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

+(NSString *)getUTCNowWithParseFormat
{
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:tz];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setTimeZone:tz];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *theDate = [dateFormat stringFromDate:now];
    NSString *theTime = [timeFormat stringFromDate:now];
    NSString * dateString =[NSString stringWithFormat: @"%@T%@.000Z",theDate,theTime];
    return dateString;
}
@end
