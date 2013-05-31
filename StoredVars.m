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
@synthesize episodeId;


+ (StoredVars*) sharedInstance {
    static StoredVars *myInstance = nil;
    if (myInstance == nil) {
        myInstance = [[[self class] alloc] init];
        myInstance.userId = nil;
        myInstance.episodeId = nil;
    }
    return myInstance;
}
@end
