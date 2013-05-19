//
//  StoredVars.m
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "StoredVars.h"

@implementation StoredVars
@synthesize userId;

+ (StoredVars*) sharedInstance {
    static StoredVars *myInstance = nil;
    if (myInstance == nil) {
        myInstance = [[[self class] alloc] init];
        myInstance.userId = nil;
    }
    return myInstance;
}
@end
