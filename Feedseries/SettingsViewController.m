//
//  SettingsViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "SettingsViewController.h"
#import "PKRevealController.h"
#import "StoredVars.h"


#define deleteSmartURL [NSURL URLWithString: @"http://feedseries.herokuapp.com/deleteSmartPhone"]

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)btnLogout:(id)sender {
    
    Boolean *response=[self deleteToken];
    if(response==YES){
        NSString *saveString=@"666";
        NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
        [defaults  setObject:saveString forKey:@"userLogued"];
        [defaults synchronize];
    
        UIViewController *login = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MainStoryboard"];
    
        [self presentViewController:login animated:YES completion:nil];
    }
}

-(Boolean)deleteToken
{
    NSString *jsonString =[NSString stringWithFormat: @"{'email':'%@','smartType':'apple'}",[StoredVars sharedInstance].userId];
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:deleteSmartURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request addValue:@"application/json"forHTTPHeaderField:@"Content-Type" ];
    
    NSError        *error = nil;
    NSHTTPURLResponse* response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
    
    NSMutableString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [responseString dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &error];
    
    if([response statusCode]==200){
        return YES;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Ups!, try it again"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.revealController setMinimumWidth:100.0f maximumWidth:120.0f forViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
