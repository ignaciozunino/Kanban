//
//  UIFont+CustomFonts.m
//  Kanban
//
//  Created by Guillermo Apoj on 24/4/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "UIFont+CustomFonts.h"

@implementation UIFont (KBNCustomFonts)
+(NSDictionary*)getKBNNavigationBarFont{
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 1.0f);
    shadow.shadowColor = [UIColor darkGrayColor];
 return  @{
    NSForegroundColorAttributeName: [UIColor darkGrayColor],
    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Light" size:20.0f],
    NSShadowAttributeName: shadow
    };
}

@end
