//
//  KBNProxy.m
//  Kanban
//
//  Created by Guillermo Apoj on 4/16/15.
//  Copyright (c) 2015 Globant. All rights reserved.
//

#import "KBNProxy.h"


@implementation KBNProxy
+(KBNProxy *) sharedInstance{
    static  KBNProxy *inst = nil;
    @synchronized(self){
        if (!inst) {
            inst = [[self alloc] init];
        }
    }
    return inst;
}

-(void)createUser:(KBNUser*)user{
    [KBNParseAPIManager createUser:user];

}
@end
