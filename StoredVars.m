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
@synthesize deviceToken;


+ (StoredVars*) sharedInstance {
    static StoredVars *myInstance = nil;
    if (myInstance == nil) {
        myInstance = [[[self class] alloc] init];
        myInstance.userId = nil;
        myInstance.episodeId = nil;
        myInstance.deviceToken = nil;
    }
    return myInstance;
}
@end
