//
//  SettingsViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "SettingsViewController.h"
#import "PKRevealController.h"

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
    NSString *saveString=@"666";
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults  setObject:saveString forKey:@"userLogued"];
    [defaults synchronize];
    //[self performSegueWithIdentifier:@"Login" sender:self];
    UIViewController *login = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MainStoryboard"];
    
    [self presentViewController:login animated:YES completion:nil];
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
