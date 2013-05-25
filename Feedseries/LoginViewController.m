//
//  LoginViewController.m
//  Feedseries
//
//  Created by Brian Krochik on 18/05/13.
//  Copyright (c) 2013 Brian Krochik. All rights reserved.
//

#import "LoginViewController.h"
#import "StoredVars.h"
#import "PKRevealController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)
#define kjsonURL [NSURL URLWithString: @"http://feedseries.herokuapp.com/getUser"]

@interface LoginViewController ()
{
    IBOutlet UIButton *BtnLogin;
    NSDictionary *jsonResults;
    PKRevealController *revealController;
}
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Genero menu lateral
    NSDictionary *options = @{
                              PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
                              PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
                              };
    
    //Init reveal menu
    UIViewController *leftViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySettings"];
    
    UINavigationController *frontViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"MySeries"];
    
    revealController = [PKRevealController revealControllerWithFrontViewController:frontViewController leftViewController:leftViewController options:options];
    
    //Inicializo componentes
    self.InputMail.delegate = self;
    self.InputPass.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{        
    //Si estoy logueado voy a los tabs
    if ([self isLogged]!=true) {
        [self presentViewController:revealController animated:YES completion:nil];
    }
}
- (IBAction)BtnLogin:(id)sender {
    //Callout login
    NSError* error = nil;
    NSString *loginUri= [NSString stringWithFormat:@"%@?email=%@&pass=%@",kjsonURL,self.InputMail.text,self.InputPass.text];
    NSData* data= [NSData dataWithContentsOfURL:[NSURL URLWithString:loginUri] options:NSDataReadingUncached error:&error];
    [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    
    NSLog(@"--login---%@---------",loginUri);
    if (error) {
        NSLog(@"---------%@", [error localizedDescription]);
    } else {
        NSLog(@"Data has loaded successfully.");
    }
}

- (void) fetchedData:(NSData *)responseData {
    @try
    {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        jsonResults = [json objectForKey:@"data"];
        if(jsonResults!=[jsonResults objectForKey:@"email"])
            [self saveLogin];
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error al intentar ingresar, intentelo nuevamente"]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        NSLog(@"-----%@---------",ex);
        [alert show];
    }
}

//Save
- (void)saveLogin
{
    NSString *saveString=self.InputMail.text;
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    [defaults  setObject:saveString forKey:@"userLogued"];
    [defaults synchronize];
    //[self performSegueWithIdentifier:@"MySeries" sender:self];
    [self presentViewController:revealController animated:YES completion:nil];
}

//Check if user is logged
- (BOOL)isLogged
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end