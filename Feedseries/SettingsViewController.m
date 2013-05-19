//
//  SettingsViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "SettingsViewController.h"

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
    [self performSegueWithIdentifier:@"Login" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
