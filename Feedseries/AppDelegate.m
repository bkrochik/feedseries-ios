//
//  AppDelegate.m
//  Feedseries
//
//  Created by Brian Krochik on 15/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginUtils.h"
#import "StoredVars.h"
#import "PKRevealController.h"
#import "Reachability.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //Genero menu lateral
    NSDictionary *options = @{
                              PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
                              PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
                              };
    
    PKRevealController *revealController;
    //Init reveal menu
    UIViewController *leftViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySettings"];
    leftViewController.title=@"Left Controller";
    
    UITabBarController *frontViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySeries"];
    frontViewController.title=@"Front Controller";
    
    revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController leftViewController:leftViewController options:options];
    revealController.title=@"Reveal Controller";
    
    //Reachability status
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Please check your internet conection and try it again."]
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        });
    };
    
    [reach startNotifier];
    
    //Si estoy logueado voy a los tabs
    if ([LoginUtils isLogged]==true) {
        self.window.rootViewController =revealController;
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([LoginUtils isLogged]==true) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNews" object:self];
        PKRevealController *viewController=self.window.rootViewController;
        UITabBarController *tab =viewController.frontViewController;
        [tab setSelectedIndex:0];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults  setObject: deviceToken forKey:@"deviceToken"];
    [defaults synchronize];
    [StoredVars sharedInstance].deviceToken=deviceToken; 
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//Notifications
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if(![reach isReachable])
    {
    }
}

@end
