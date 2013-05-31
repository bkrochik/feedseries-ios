//
//  UserLoginController.m
//  Feedseries
//
//  Created by Brian Krochik on 27/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "LoginUtils.h"
#import "StoredVars.h"

@implementation LoginUtils


//Check if user is logged
+ (BOOL)isLogged
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    NSString *loadString=[defaults  objectForKey:@"userLogued"];
    if([loadString isEqualToString:@"666"])
        return false;
    else{
        [StoredVars sharedInstance].userId=loadString;
        return true;
    }
}

@end
